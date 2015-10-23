// Copyright 2015 Google Inc. All Rights Reserved.
// Licensed under the Apache License, Version 2.0 (the "License");

#include <string>
#include "pcre2posix.h"

using std::string;

extern "C" int LLVMFuzzerTestOneInput(const unsigned char *data, size_t size) {
  if (size < 1) return 0;
  regex_t preg;
  string str(reinterpret_cast<const char*>(data), size);
  string pat(str);
  if (0 == regcomp(&preg, pat.c_str(), data[size/2] & ~REG_NOSUB)) {
    // regmatch_t pmatch[5];
    // regexec(&preg, s.c_str(), 5, pmatch, 0);
    regfree(&preg);
  }
  return 0;
}
