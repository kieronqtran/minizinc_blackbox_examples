# Black-Box Example for Constraints and Local Search

This example taken from [Coursera Monkey Example for Constraints and Local Search](https://www.coursera.org/learn/solving-algorithms-discrete-optimization/lecture/6aLsX/3-4-2-constraints-and-local-search)

# Build the blackbox program before run the MiniZinc Model

```bash
cd bb_monkey_cpp
make install
cd ..
```

NOTE: the project based on cmake so that it will build on x86-64 if your system runs on arm64 then run `CFLAGS="-arch arm64" CXXFLAGS="-arch arm64" make install` to install
