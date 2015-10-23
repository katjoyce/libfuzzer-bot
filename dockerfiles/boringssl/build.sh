#!/bin/bash
set -e

mkdir -p /work/boringssl
cd /work/boringssl

cmake -GNinja -DCMAKE_C_COMPILER=$CC -DCMAKE_CXX_COMPILER=$CXX \
  -DCMAKE_C_FLAGS="$CFLAGS" -DCMAKE_CXX_FLAGS="$CXXFLAGS" \
  /src/boringssl/
ninja

$CXX $CXXFLAGS /src/boringssl/fuzzer.cc /work/libfuzzer/*.o -o fuzzer \
  ./ssl/libssl.a  ./crypto/libcrypto.a \
  -I /src/boringssl/include -std=c++11

cp /src/boringssl/server.{pem,key} /work/boringssl
