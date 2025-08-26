# Wind benchmark (MiniZinc)

MiniZinc wind-farm example for quick benchmarking.

## Structure
- models/wind.mzp — project file
- model/windfarm.mzn — main model
- data/windfarm00.dzn, windfarm01.dzn — instances
- configs/gecode_bb.mpc — optional solver config

## Requirements
- MiniZinc (with Gecode). macOS:
  ```bash
  brew install --cask minizinc
  ```

## Run
```bash
cd benchmarks/wind
minizinc --solver Gecode model/windfarm.mzn data/windfarm00.dzn
# or using the project file:
minizinc models/wind.mzp --solver Gecode --data data/windfarm01.dzn
```
