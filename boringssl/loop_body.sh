#!/bin/bash
# Copyright 2015 Google Inc. All Rights Reserved.
# Licensed under the Apache License, Version 2.0 (the "License");

export PATH="$HOME/llvm-build/bin:$PATH"
P=$(cd $(dirname $0) && pwd)

mkindex() {
  sudo mv $1 /var/www/html/$prefix-$1
  (cd /var/www/html/; sudo $P/../common/mkindex.sh index.html *log)
}

update_trunk() {
  if [ -d boringssl ]; then
    (cd boringssl && git pull)
  else
    git clone https://boringssl.googlesource.com/boringssl
  fi
}

build_fuzzers() {
  ln -sf $HOME/llvm/lib/Fuzzer .
  for f in Fuzzer/*cpp; do clang++ -std=c++11 -c $f -IFuzzer & done
  wait
  ar q libFuzzer.a *.o
  rm -rf build
  mkdir build
  cp libFuzzer.a boringssl
  (cd build; CC=clang CXX=clang++ cmake -GNinja -DFUZZ=1 ../boringssl && ninja)
}

max_len() {
  case $1 in
    privkey)
      echo 2048
    ;;
    cert)
      echo 3072
      ;;
    server)
      echo 1024
      ;;
    client)
      echo 4096
      ;;
    *)
      echo invalid size
      ;;
  esac
}

MAX_TOTAL_TIME=300

# Make asan less memory-hungry, strip paths, intercept abort(), no lsan.
export ASAN_OPTIONS=coverage=1:quarantine_size_mb=10:strip_path_prefix=`pwd`/:handle_abort=1:detect_leaks=0
J=$(grep CPU /proc/cpuinfo | wc -l)

L=$(date +%Y-%m-%d-%H-%M-%S.log)
echo =========== STARTING $L ==========================
echo =========== PULL libFuzzer && (cd Fuzzer; svn up)
echo =========== UPDATE TRUNK   && update_trunk
echo =========== BUILD && build_fuzzers

echo =========== SYNC CORPORA and BUILD
mkdir -p CORPORA/ARTIFACTS CORPORA/
BUCKET=gs://ssl-fuzzing-corpora
fuzzers=$(cd boringssl/fuzz/; ls *.cc | sed 's/\.cc$//g' | grep -v server)
mkdir -p CORPORA/ARTIFACTS
for f in $fuzzers; do
  mkdir -p CORPORA/$f
done
gsutil -m rsync -r $BUCKET/CORPORA CORPORA
gsutil -m rsync -r CORPORA $BUCKET/CORPORA
rm -f *.sancov
for f in $fuzzers; do
  echo =========== FUZZING $f
  ./build/fuzz/$f -max_len=$(max_len $f) -jobs=$J -workers=$J\
    -max_total_time=$MAX_TOTAL_TIME CORPORA/$f boringssl/fuzz/${f}_corpus  >> $L 2>&1
done
prefix=pass # TODO

for f in $fuzzers; do
  echo ================== COVERED FUNCTIONS: $f >> $L
  sancov  -covered_functions -obj build/fuzz/client client*sancov |  cat -n >> $L
done

echo =========== UPDATE WEB PAGE
if [ "$DRY_RUN" != "1" ]; then
  mkindex $L
fi


