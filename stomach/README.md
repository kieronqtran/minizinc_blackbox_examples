# Black-Box Example for Discrete Langrange Multiplier Methods

This example taken from [Coursera Pricess Example for Discrete Langrange Multiplier Methods](https://www.coursera.org/learn/solving-algorithms-discrete-optimization/lecture/EkDlK/3-4-4-simulated-annealing)

# Build the blackbox program before run the MiniZinc Model

```bash
cd bb_stomach_py
make install
cd ..
```

NOTE: the project based on cmake so that it will build on x86-64 if your system runs on arm64 then run `CFLAGS="-arch arm64" CXXFLAGS="-arch arm64" make install` to install

