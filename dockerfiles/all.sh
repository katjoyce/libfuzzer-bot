#!/bin/bash
set -e -x

docker build -t libfuzzer/base base/
docker build -t libfuzzer/base-clang base-clang/
docker build -t libfuzzer/base-fuzzer base-fuzzer/

docker build -t libfuzzer/boringssl boringssl/
docker build -t libfuzzer/pcre2 pcre2/
docker build -t libfuzzer/freetype2 freetype2/
