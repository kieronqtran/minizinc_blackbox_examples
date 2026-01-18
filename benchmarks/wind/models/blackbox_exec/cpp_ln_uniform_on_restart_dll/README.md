# C++ shared library blackbox: ln(uniform)

This project builds a shared library for MiniZinc’s `experimental/blackbox.mzn` via `::blackbox_dll(...)`.

It exports the required symbol:

- `extern "C" void fzn_blackbox(...)`

The library expects **2 float inputs** `(lb, ub)` and produces **1 float output** `ln(u)` where `u ~ Uniform(lb, ub)`.

## Build

```bash
cmake -S . -B build
cmake --build build -j
```

Output:

- `build/libbb_ln_uniform_on_restart.so` (name may be under `build/` directly depending on generator)

## MiniZinc usage

Example:

```minizinc
include "experimental/blackbox.mzn";

var float: y;
constraint blackbox([], [0.0, 1.0], [], [y])
  ::blackbox_dll("../blackbox_exec/cpp_ln_uniform_on_restart_dll/build/libbb_ln_uniform_on_restart.so");
```

Notes:
- `ln(u)` is only defined for $u>0$, so the implementation clamps the lower bound to a tiny positive number.
- You can pass an optional integer seed as the first integer input to reseed per call.
