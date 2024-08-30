# Black-Box Example for Escaping Local Minima- Restart

This example taken from [Coursera Pricess Stomach for Escaping Local Minima- Restart](https://www.coursera.org/learn/solving-algorithms-discrete-optimization/lecture/KaAoU/3-4-3-escaping-local-minima-restart)

# Build the blackbox program before run the MiniZinc Model

```bash
cd bb_breast_search_cpp
make install
cd ..
```

NOTE: the project based on cmake so that it will build on x86-64 if your system runs on arm64 then run `CFLAGS="-arch arm64" CXXFLAGS="-arch arm64" make install` to install
