cmake_minimum_required(VERSION 3.16)
project(bb_ln_uniform_on_restart VERSION 0.1.0 LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

add_library(bb_ln_uniform_on_restart SHARED
  src/ln_uniform_on_restart.cpp
)

# Match the rest of this repo: use .so even on macOS.
set_target_properties(bb_ln_uniform_on_restart PROPERTIES SUFFIX ".so")

if (MSVC)
  target_compile_options(bb_ln_uniform_on_restart PRIVATE /W4)
else()
  target_compile_options(bb_ln_uniform_on_restart PRIVATE -Wall -Wextra -Wpedantic)
endif()
