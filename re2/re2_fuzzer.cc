// Copyright 2015 Google Inc. All Rights Reserved.
// Licensed under the Apache License, Version 2.0 (the "License");

#include <string>
#include "re2/re2.h"

using std::string;

extern "C" int LLVMFuzzerTestOneInput(const unsigned char *data, size_t size) {
  if (size < 1) return 0;
  RE2::Options opt;
  opt.set_log_errors(false);
  string str(reinterpret_cast<const char*>(data), size);
  string pat(str);
  RE2 re(pat, opt);
//  if (re.ok()) {
//    RE2::FullMatch(str, re);
//  }
  return 0;
}
