#!/usr/bin/env python3

from sys import stdin, stderr
from typing import List, Tuple
import random

def bb_simulator(starts: List[int], _: List[float]) -> Tuple[List[int], List[float]]:
  output_durations = [ random.randint(-1, 2) for i in range(len(starts))]
  return (output_durations, [])

if __name__ == "__main__":
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
    (int_out, float_out) = bb_simulator(integers, floats)

    # Communicate output to encapsulating process
    print(
        f"{' '.join([str(i) for i in int_out])}; {' '.join([str(f) for f in float_out])};",
        flush=True,
    )
