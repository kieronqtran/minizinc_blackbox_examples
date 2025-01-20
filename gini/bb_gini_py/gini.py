from typing import List

def gini(x: List[int]) -> float:
  x_clone = sorted(x)
  n = len(x_clone)
  diffs = sum((2 * i - n - 1) * xi for i, xi in enumerate(x_clone, 1))
  return diffs / (n * sum(x_clone))
