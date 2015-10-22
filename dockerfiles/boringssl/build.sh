#!/bin/bash
set -e

cd /work/boringssl

CC_FLAGS="$SANITIZER_OPTIONS $COVERAGE_OPTIONS -g"
CXX_FLAGS=$CC_FLAGS

cmake -GNinja -DCMAKE_C_COMPILER=$CC -DCMAKE_CXX_COMPILER=$CXX \
  -DCMAKE_C_FLAGS="$CC_FLAGS" -DCMAKE_CXX_FLAGS="$CXX_FLAGS" \
  /src/boringssl/
ninja

find . -name "lib*.a"

for f in /src/llvm/lib/Fuzzer/*cpp; do $CXX $SANITIZER_OPTIONS \
  -g -std=c++11 -c $f -IFuzzer & done
wait

$CXX /src/boringssl/fuzzer.cc *.o $CC_FLAGS -o fuzzer \
  ./ssl/libssl.a  ./crypto/libcrypto.a \
  -I /src/boringssl/include -std=c++11

  cp /src/boringssl/server.{pem,key} /work/boringssl
