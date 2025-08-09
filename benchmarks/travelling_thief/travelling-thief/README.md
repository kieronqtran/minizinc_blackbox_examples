# Black-Box Travelling Thief Example

This example taken from [Travelling Thief Example](https://github.com/MiniZinc/mzn-challenge/blob/develop/2023/travelling-thief/ttp.mzn)

# Build the blackbox program before run the MiniZinc Model

```bash
cd bb_travelling_thief_cpp
make install
cd ..
```

NOTE: the project based on cmake so that it will build on x86-64 if your system runs on arm64 then run `CFLAGS="-arch arm64" CXXFLAGS="-arch arm64" make install` to install
