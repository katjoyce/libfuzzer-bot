#!/bin/bash
# Copyright 2015 Google Inc. All Rights Reserved.
# Licensed under the Apache License, Version 2.0 (the "License");
export PATH="$HOME/llvm-build/bin:$PATH"
NAME=$1 # E.g. asan
SAN=$2  # E.g. -fsanitize=address
COV=$3  # E.g. -fsanitize-coverage=edge,8bit-counters
(
rm -rf $NAME
cp -rf pcre $NAME
cd $NAME
./autogen.sh
CXX="clang++ $SAN $COV" CC="clang -g $SAN $COV" CCLD="clang++ $SAN $COV" ./configure --enable-static --disable-shared
make -j
)
ln -sf $HOME/llvm/lib/Fuzzer .
for f in Fuzzer/*cpp; do clang++ -std=c++11 -c $f -IFuzzer & done
wait
clang++ libfuzzer-bot/pcre/pcre_fuzzer.cc -I${NAME}/src -g $SAN $COV -Wl,--whole-archive  ${NAME}/.libs/*.a -Wl,-no-whole-archive Fuzzer*.o -o pcre_${NAME}_fuzzer
