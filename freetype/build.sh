#!/bin/bash
# Copyright 2015 Google Inc. All Rights Reserved.
# Licensed under the Apache License, Version 2.0 (the "License");
export PATH="$HOME/llvm-build/bin:$PATH"
NAME=$1 # E.g. asan
SAN=$2  # E.g. -fsanitize=address
COV=$3  # E.g. -fsanitize-coverage=edge,8bit-counters

(
  rm -rf $NAME
  cp -rf freetype2 $NAME
  cd $NAME
  ./autogen.sh
  # harfbuzz is disabled due to
  # https://savannah.nongnu.org/bugs/?func=detailitem&item_id=46254
  CC="clang  $SAN $COV"   ./configure --with-harfbuzz=no
  make -j
)

ln -sf $HOME/llvm/lib/Fuzzer .
for f in Fuzzer/*cpp; do clang++ -std=c++11 -c $f -IFuzzer & done
wait

clang++ -std=c++11  $NAME/src/tools/ftfuzzer/ftfuzzer.cc \
  $SAN $COV \
  *.o -I $NAME/include -I . ${NAME}/objs/.libs/libfreetype.a  \
  -lbz2 -lz -lpng -lharfbuzz -larchive -o freetype2_${NAME}_fuzzer
