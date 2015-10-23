#!/bin/bash

bash -x -e /src/scripts/build_clang.sh

OLD_ASAN_OPTIONS=$ASAN_OPTIONS
OLD_CFLAGS=$CFLAGS
OLD_CXX_FLAGS=$CXXFLAGS
OLD_PATH=$PATH

export CC="/work/llvm/bin/clang"
export CXX="/work/llvm/bin/clang++"
export PATH=/work/llvm/bin:$PATH
export CFLAGS="$CFLAGS $SANITIZER_OPTIONS $COVERAGE_OPTIONS"
export CXXFLAGS="$CXXFLAGS $SANITIZER_OPTIONS $COVERAGE_OPTIONS"

# asan could get in the way of configure scripts.
export ASAN_OPTIONS=""

# build libfuzzer
mkdir -p /work/libfuzzer
cd /work/libfuzzer
for f in /src/llvm/lib/Fuzzer/*cpp; do
  clang++ -std=c++11 $OLD_CXXFLAGS $SANITIZER_OPTIONS -IFuzzer -c $f &
done
wait

OLD_ASAN_OPTIONS=$ASAN_OPTIONS
# asan could get in the way of configure scripts.
export ASAN_OPTIONS=""
bash -x -e /src/scripts/build.sh

export ASAN_OPTIONS=$OLD_ASAN_OPTIONS
bash -x -e /src/scripts/run.sh
