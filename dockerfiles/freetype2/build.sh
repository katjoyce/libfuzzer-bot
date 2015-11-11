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
bash /src/freetype2/configure

echo =========== MAKE
make -j 16

$CXX $CXXFLAGS -std=c++11 /src/freetype2/src/tools/ftfuzzer/ftfuzzer.cc \
  *.o /work/libfuzzer/*.o \
  -larchive -I /src/freetype2/include -I . .libs/libfreetype.a  \
   -o freetype2_fuzzer
