#!/bin/bash

bash -x -e /src/scripts/build_clang.sh

export CC="/work/llvm/bin/clang"
export CXX="/work/llvm/bin/clang++"
export PATH=/work/llvm/bin:$PATH

bash -x -e /src/scripts/build.sh
bash -x -e /src/scripts/run.sh
