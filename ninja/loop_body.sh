#!/bin/bash
# Copyright 2015 Google Inc. All Rights Reserved.
# Licensed under the Apache License, Version 2.0 (the "License");
P=$(cd $(dirname $0) && pwd)
COMMON=$P/../common

MAX_LEN=32
MAX_TOTAL_TIME=30
BUCKET=gs://ninja-build-fuzzing-corpora
CORPUS=CORPORA/C1
ARTIFACTS=CORPORA/ARTIFACTS
BUILD_SH=$P/build.sh

SAN=-fsanitize=address
COV=-fsanitize-coverage=edge,8bit-counters
USE_COUNTERS=1
ASAN_OPTIONS=detect_leaks=0

TARGET_NAME=ninja

update_trunk() {
  if [ -d ninja ]; then
    (cd ninja && git pull)
  else
    git clone https://github.com/martine/ninja.git
  fi
}

DRY_RUN=0

source $COMMON/loop_body.sh
