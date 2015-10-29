#!/bin/bash
# Copyright 2015 Google Inc. All Rights Reserved.
# Licensed under the Apache License, Version 2.0 (the "License");
export PATH="$HOME/llvm-build/bin:$PATH"
NAME=$1 # E.g. asan
SAN=$2  # E.g. -fsanitize=address
COV=$3  # E.g. -fsanitize-coverage=edge,8bit-counters
(
rm -rf $NAME
cp -rf ninja $NAME
cd $NAME
CXX="clang++ $SAN $COV" ./configure.py --bootstrap
)
ln -sf $HOME/llvm/lib/Fuzzer .
for f in Fuzzer/*cpp; do clang++ -std=c++11 -c $f -IFuzzer & done
wait
clang++ $SAN $COV libfuzzer-bot/ninja/ninja_fuzzer.cc ./$NAME/build/libninja.a -I ninja/src Fuzzer*.o -o ninja_${NAME}_fuzzer
