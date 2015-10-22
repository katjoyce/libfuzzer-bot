#!/bin/bash
set -e

cd /src/freetype2/
if [ ! -f configure.ac ]
then
  ./autogen.sh
fi

mkdir -p /work/freetype2
cd /work/freetype2
echo =========== CONFIGURE
CC=$CC CFLAGS="$CC_FLAGS $SANITIZER_OPTIONS $COVERAGE_OPTIONS" ASAN_OPTIONS="" bash /src/freetype2/configure

echo =========== MAKE
make -j 16

echo =========== BUILD libFuzzer
for f in /src/llvm/lib/Fuzzer/*cpp; do $CXX $CXX_FLAGS $SANITIZER_OPTIONS \
  -std=c++11 -c $f -IFuzzer & done
wait

# -lbz2 -lz -lpng -lharfbuzz
$CXX -std=c++11  /src/freetype2/src/tools/ftfuzzer/ftfuzzer.cc \
  $CLANG_OPTIONS $SANITIZER_OPTIONS $COVERAGE_OPTIONS \
  *.o -I /src/freetype2/include -I . .libs/libfreetype.a  \
   -o freetype2_fuzzer
