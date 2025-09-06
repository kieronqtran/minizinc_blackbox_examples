# Wind benchmark (MiniZinc)

MiniZinc wind-farm example for quick benchmarking.

## Structure
- models/wind.mzp — project file
- models/model/windfarm01.mzn — the model type 01 
- models/model/windfarm02.mzn — the model type 02
- data/windfarm00.dzn, windfarm01.dzn — instances
- configs/gecode_bb.mpc — optional solver config
- analysing_results.ipynb - the jupyter notebook for the charts
- start_bench.py - the script to run the benchmarks

## Requirements
- MiniZinc (with Gecode has Blackbox version init). macOS:
  ```bash
  brew install --cask minizinc
  ```
- Install conda
  ```bash
  brew install --cask miniconda
  ```

- Install the conda environment
  ```bash
  conda env create -f .conda.yml
  ```

## Run
```bash
cd benchmarks/wind
conda activate minizinc-windfarm-benchmark

minizinc --solver Gecode model/windfarm.mzn data/windfarm00.dzn
# or using the project file:
minizinc models/wind.mzp --solver Gecode --data data/windfarm01.dzn

# or the benchmark:
python start_bench.py
```

