#!/usr/bin/env python3

from sys import stdin, stderr
from typing import List, Tuple
import random
from itertools import batched

def cumulative(s: List[int], d: List[int], r: List[int], b: int):
    Tasks = [i for i in range(len(s)) if r[i] > 0 and d[i] > 0]
    for j in Tasks:
        resource_sum = sum(
            (s[i] <= s[j] < s[i] + d[i]) * r[i] for i in Tasks
        )
        if b < resource_sum:
            return False
    return True

def bb_simulator(inputs: List[int], _: List[float]) -> Tuple[List[int], List[float]]:
  n_wukong, n_fire, *o_inputs = inputs
  starts, durations, reqW = list(batched(o_inputs, n_fire))
  r = cumulative(starts, durations, reqW, n_wukong)
  return (starts if r else [0] * len(inputs), [])

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
