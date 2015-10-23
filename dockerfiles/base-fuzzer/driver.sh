#!/bin/bash

bash -x -e /src/scripts/build_clang.sh

export CC="/work/llvm/bin/clang"
export CXX="/work/llvm/bin/clang++"
export PATH=/work/llvm/bin:$PATH

OLD_ASAN_OPTIONS=$ASAN_OPTIONS
# asan could get in the way of configure scripts.
export ASAN_OPTIONS=""
bash -x -e /src/scripts/build.sh

export ASAN_OPTIONS=$OLD_ASAN_OPTIONS
bash -x -e /src/scripts/run.sh
