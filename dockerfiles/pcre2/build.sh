#!/bin/bash
set -e

cd /src/pcre2/
if [ ! -f configure ]
then
  ./autogen.sh
fi

# pcre2 doesn't build outside of source directory
CC="$CC $SANITIZER_OPTIONS $COVERAGE_OPTIONS -g" ./configure
make -j 16

for f in /src/llvm/lib/Fuzzer/*cpp; do clang++ -std=c++11 $SANITIZER_OPTIONS -g -c $f -IFuzzer & done
wait

$CXX $SANITIZER_OPTIONS $COVERAGE_OPTIONS -g -std=c++11 pcre2_fuzzer.cc \
  *.o -I src \
   -o pcre2_fuzzer

echo =========== RUN freetype2_fuzzer
export ASAN_OPTIONS=quarantine_size_mb=10 # Make asan less memory-hungry.
