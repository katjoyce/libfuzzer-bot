#!/bin/bash
# Copyright 2015 Google Inc. All Rights Reserved.
# Licensed under the Apache License, Version 2.0 (the "License");
sudo apt-get update && sudo apt-get install git g++ python apache2 screen  -y
git clone https://github.com/google/libfuzzer-bot.git

libfuzzer-bot/common/get_llvm.sh
libfuzzer-bot/common/build_llvm.sh
ln -sf llvm/lib/Fuzzer .
