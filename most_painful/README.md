# Black-Box Example for Most Painful

This example taken from [Coursera Pricess Example for Most Painful](https://www.coursera.org/learn/solving-algorithms-discrete-optimization/lecture/fnPXm/3-4-5-tabu-list)

# Build the blackbox program before run the MiniZinc Model

```bash
cd bb_most_painful_cpp
make install
cd ..
```

NOTE: the project based on cmake so that it will build on x86-64 if your system runs on arm64 then run `CFLAGS="-arch arm64" CXXFLAGS="-arch arm64" make install` to install
