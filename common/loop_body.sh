#!/bin/bash
# Copyright 2015 Google Inc. All Rights Reserved.
# Licensed under the Apache License, Version 2.0 (the "License");

export PATH="$HOME/llvm-build/bin:$PATH"

mkindex() {
  sudo mv $1 /var/www/html/$prefix-$1
  (cd /var/www/html/; sudo $P/../common/mkindex.sh index.html *log)
}

dump_coverage() {
  echo ===================================================================
  echo ==== FUNCTION-LEVEL COVERAGE: THESE FUNCTIONS ARE *NOT* COVERED ===
  echo ===================================================================
  sancov.py print *sancov  2> /dev/null |\
    sancov.py missing $1 2> /dev/null |\
    llvm-symbolizer -obj $1 -inlining=0 -functions=none |\
    grep /func/ |\
    sed "s#.*func/##g" |\
    sort --field-separator=: --key=1,1 --key=2n,2 --key=3n,3 | cat -n
}

# Make asan less memory-hungry, strip paths, intercept abort().
export ASAN_OPTIONS=quarantine_size_mb=10:strip_path_prefix=$HOME/:handle_abort=1:$ASAN_OPTIONS
J=$(grep CPU /proc/cpuinfo | wc -l )

L=$(date +%Y-%m-%d-%H-%M-%S.log)
echo =========== STARTING $L ==========================
echo =========== PULL libFuzzer && (cd Fuzzer; svn up)
echo =========== UPDATE TRUNK   && update_trunk
echo =========== SYNC CORPORA and BUILD
mkdir -p $ARTIFACTS $CORPUS
# These go in parallel.
if [ "$DRY_RUN" != "1" ]; then
  (gsutil -m rsync -r $BUCKET/CORPORA CORPORA; gsutil -m rsync -r CORPORA $BUCKET/CORPORA) &
fi
$BUILD_SH san_cov $SAN $COV > san_cov_build.log 2>&1 &
$BUILD_SH func    -fsanitize=shift -fsanitize-coverage=func > func_build.log 2>&1 &
wait

echo =========== FUZZING
./${TARGET_NAME}_san_cov_fuzzer \
  -max_len=$MAX_LEN $CORPUS  -artifact_prefix=$ARTIFACTS/ -jobs=$J \
  -workers=$J -max_total_time=$MAX_TOTAL_TIME -use_counters=$USE_COUNTERS $LIBFUZZER_EXTRA_FLAGS > $L 2>&1
exit_code=$?
case $exit_code in
  0) prefix=pass
    ;;
  *) prefix=FAIL
    ;;
esac
echo =========== DUMP COVERAGE
rm -f *sancov
UBSAN_OPTIONS=coverage=1 ./${TARGET_NAME}_func_fuzzer -max_len=$MAX_LEN $CORPUS -runs=0 > func_run.log 2>&1
dump_coverage ${TARGET_NAME}_func_fuzzer >> $L
echo =========== UPDATE WEB PAGE
if [ "$DRY_RUN" != "1" ]; then
  mkindex $L
fi
echo =========== DONE
echo
echo
