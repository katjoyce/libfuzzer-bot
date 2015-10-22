#!/bin/sh
set -e

mkdir -p /work/llvm
cd /work/llvm

if [ ! -f CMakeCache.txt ]
then
    cmake -G "Ninja" -DCMAKE_BUILD_TYPE=Release /src/llvm
fi

ninja
