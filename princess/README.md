# Black-Box Example for Local Search

This example taken from [Coursera Pricess Example for Local Search](https://www.coursera.org/learn/solving-algorithms-discrete-optimization/lecture/1YLYy/3-4-1-local-search)

# Build the blackbox program before run the MiniZinc Model

```bash
cd bb_pricess_cpp
make install
cd ..
```

NOTE: the project based on cmake so that it will build on x86-64 if your system runs on arm64 then run `CFLAGS="-arch arm64" CXXFLAGS="-arch arm64" make install` to install
