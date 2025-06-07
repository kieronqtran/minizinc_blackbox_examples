#!/usr/bin/env python3

from sys import stdin, stderr
from typing import List, Tuple, Dict
import matlab.engine as matlab
import os
import numpy as np
import atexit
import signal
import uuid
import time
import argparse
from queue import Queue
import logging
import logging.handlers

# Directory for log file
current_dir = os.path.dirname(os.path.abspath(__file__))

# Create a queue for log events
log_queue = Queue()

# Create a handler that enqueues log records
queue_handler = logging.handlers.QueueHandler(log_queue)

# Create a handler that writes log records to a file
file_handler = logging.FileHandler(os.path.join(current_dir, 'application.log'))
formatter = logging.Formatter('%(asctime)s - %(name)s - %(levelname)s - %(message)s')
file_handler.setFormatter(formatter)

# Configure the root logger to send all records to the queue
root_logger = logging.getLogger()
root_logger.setLevel(logging.INFO)
root_logger.addHandler(queue_handler)

# Start a background listener that pulls records off the queue and writes them via file_handler
listener = logging.handlers.QueueListener(log_queue, file_handler)
listener.start()

# Ensure listener stops cleanly on exit
atexit.register(listener.stop)

# Convenient module-level logger
logger = logging.getLogger(__name__)

eng: matlab.MatlabEngine = matlab.start_matlab()

# Matlab doesn't automatic shutdown when the script terminate
# NOTE: double check if the matlab still running in the background after stopped MiniZinc
matlab_quit = lambda *args, **kwargs: eng.quit()
atexit.register(matlab_quit)
signal.signal(signal.SIGTERM, matlab_quit)
signal.signal(signal.SIGINT, matlab_quit)

# manually import to the mathlab function since the MatlabEngine often confuse where it get the functions
eng.addpath(current_dir)
logs = []
def register_cache_handler(cache_dir: str):
  def kill_handler(*args, **kwargs):
    import csv
    with open(os.path.join(cache_dir, f"{uuid.uuid4()}.csv"), 'w+') as csv_file:
      w = csv.DictWriter(csv_file, ['nurses_no', 'hits', 'time', 'cache_enabled'], lineterminator='\n')
      w.writeheader()
      w.writerows(logs)

  atexit.register(kill_handler)
  signal.signal(signal.SIGTERM, kill_handler)
  signal.signal(signal.SIGINT, kill_handler)

cache = {}
def bb_single_fatigue_score(integers: List[int], floats: List[float], is_cache: bool = True) -> Tuple[List[int], List[float]]:
  start = time.perf_counter_ns()
  nBioTypes, nurse_id, *shift = integers
  key = tuple(integers)
  if is_cache and (v := cache.get(key)):
    logs.append({'nurses_no': nurse_id, 'hits': 1, 'time': time.perf_counter_ns() - start, 'cache_enabled': is_cache})
    # logger.info(f"nurse_no: {nurse_id}, hits: {1}, time: {time.perf_counter_ns() - start}, cache_enabled: {is_cache}")
    return ([v,], [])
  # running in sequence code
  _,Dv,_,_,_,_,_ = eng.evalnumberedpattern(
      shift,
      0,
      9999,
      9999,
      9999,
      9999,
      9999,
      0,
      nBioTypes,
      nargout=7
    )
  nDays = len(shift)
  Dv = np.array(Dv._data)*100
  Dv = Dv[0:2400*nDays]

  cache[key] = int(Dv.max())
  logs.append({'nurses_no': nurse_id, 'hits': 0, 'time': time.perf_counter_ns() - start, 'cache_enabled': is_cache})
  # logger.info(f"nurse_no: {nurse_id}, hits: {0}, time: {time.perf_counter_ns() - start}, cache_enabled: {is_cache}")
  return ([cache[key]], [])

def bb_fatigue_score(integers: List[int], floats: List[float], is_cache: bool = False) -> Tuple[List[int], List[float]]:
  start = time.perf_counter_ns()
  nBioTypes, nNurses, nDays, *others = integers
  nNurseBioType = others[:nBioTypes]
  nShift = np.array(others[nBioTypes:]).reshape(nNurses, nDays)
  temp = np.zeros((nNurses,))
  # running in sequence code
  for n in range(0, nNurses):
    _,Dv,_,_,_,_,_ = eng.evalnumberedpattern(
        nShift[n].tolist(),
        0,
        9999,
        9999,
        9999,
        9999,
        9999,
        0,
        nNurseBioType[n],
        nargout=7
      )
    Dv = np.array(Dv._data)*100
    Dv = Dv[0:2400*nDays]
    # Dv=Dv.reshape(-1,2400)
    Dv=np.max(Dv,axis=1)
    temp[n] = Dv[0]

  # running the matlab function in parallel.
  # NOTE: It's dangerous and use it's carefully.
  # submit running the async function in backgrounds
  # futures: Dict[int, matlab.FutureResult] = {}
  # for n in range(0, nNurses):
  #   futures[n] = eng.evalnumberedpattern(
  #       nShift[n].tolist(),
  #       0,
  #       9999,
  #       9999,
  #       9999,
  #       9999,
  #       9999,
  #       0,
  #       nNurseBioType[n],
  #       nargout=7,
  #       background=True
  #     )
  # # collecting the results
  # for n, future in futures.items():
  #   _,Dv,_,_,_,_,_ = future.result()
  #   Dv = np.array(Dv._data)*100
  #   Dv = Dv[0:2400*nDays]
  #   # Dv=Dv.reshape(-1,2400)
  #   Dv=np.max(Dv,axis=1)
  #   temp[n] = Dv[0]

  logs.append({'nurses_no': -1, 'hits': 0, 'time': time.perf_counter_ns() - start, 'cache_enabled': is_cache})
  return ([int(temp.max())], [])

if __name__ == "__main__":
  parser = argparse.ArgumentParser(description="Run fatigue score calculation")
  parser.add_argument("--single", action="store_true", help="Use single fatigue score computation")
  parser.add_argument("--cache", action="store_true", help="if the function is using cache")
  parser.add_argument("--cache_dir", default="cache", help="Directory of cache results")
  args = parser.parse_args()

  # Choose the appropriate function based on the command-line flag
  compute = bb_single_fatigue_score if args.single else bb_fatigue_score
  register_cache_handler(os.path.join(current_dir, args.cache_dir))

  # Continuously read lines from stdin until the pipe is closed
  for line in stdin:
    # Parse the input line
    parts = line.split(";")
    assert (
      len(parts) == 3
    ), f"Expected 2 occurences of E in the input, but split into {parts}"
    assert parts[2] in [
      "",
      "\n",
    ], f"No input expected on the same line after the last 'E', but found the following data `{parts[2]}'"
    integers = [int(i) for i in parts[0].split()]
    floats = [float(f) for f in parts[1].split()]

    # Call the (now not so) blackbox function
    # (int_out, float_out) = bb_fatigue_score(integers, floats)
    (int_out, float_out) = bb_single_fatigue_score(integers, floats)
    # (int_out, float_out) = compute(integers, floats, args.cache)

    # Communicate output to encapsulating process
    print(
      f"{' '.join([str(i) for i in int_out])}; {' '.join([str(f) for f in float_out])};",
      flush=True,
    )