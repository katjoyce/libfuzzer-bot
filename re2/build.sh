#!/bin/bash
# Copyright 2015 Google Inc. All Rights Reserved.
# Licensed under the Apache License, Version 2.0 (the "License");
export PATH="$HOME/llvm-build/bin:$PATH"
NAME=$1 # E.g. asan
SAN=$2  # E.g. -fsanitize=address
COV=$3  # E.g. -fsanitize-coverage=edge,8bit-counters
(
rm -rf $NAME
cp -rf re2 $NAME
cd $NAME
make -j CXX="clang++ $SAN $COV" CC="clang -g $SAN $COV" CCLD="clang++ $SAN $COV" CXXFLAGS="-Wall -O1 -g -pthread"
)
ln -sf $HOME/llvm/lib/Fuzzer .
for f in Fuzzer/*cpp; do clang++ -std=c++11 -c $f -IFuzzer & done
wait
clang++ $SAN $COV  libfuzzer-bot/re2/re2_fuzzer.cc ./$NAME/obj/libre2.a -I re2/ Fuzzer*.o -o re2_${NAME}_fuzzer
