#!/bin/bash
set -e

cd /src/pcre2/
if [ ! -f configure ]
then
  ./autogen.sh
fi

# pcre2 doesn't build outside of source directory
./configure
make -j 16

$CXX $CXXFLAGS pcre2_fuzzer.cc /work/libfuzzer/*.o -o pcre2_fuzzer \
  -std=c++11 -I src
