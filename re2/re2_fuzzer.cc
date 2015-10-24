// Copyright 2015 Google Inc. All Rights Reserved.
// Licensed under the Apache License, Version 2.0 (the "License");

#include <string>
#include "re2/re2.h"
#include "util/logging.h"

using std::string;

extern "C" int LLVMFuzzerTestOneInput(const unsigned char *data, size_t size) {
  if (size < 1) return 0;
  re2::FLAGS_minloglevel = 3;
  RE2::Options opt;
  unsigned f = 0;
  for (size_t i = 0; i < size; i++) f += data[i];
  if (f & 1) opt.set_encoding(RE2::Options::EncodingLatin1);
  opt.set_posix_syntax(f & 2);
  opt.set_longest_match(f & 4);
  opt.set_literal(f & 8);
  opt.set_never_nl(f & 16);
  opt.set_dot_nl(f & 32);
  opt.set_never_capture(f & 64);
  opt.set_case_sensitive(f & 128);
  opt.set_perl_classes(f & 256);
  opt.set_word_boundary(f & 512);
  opt.set_one_line(f & 1024);

  opt.set_log_errors(false);
  string str(reinterpret_cast<const char*>(data), size);
  string pat(str);
  RE2 re(pat, opt);
  if (re.ok()) {
    string m1, m2, m3, m4;
    RE2::FullMatch(str, re);
    RE2::PartialMatch(str, re);
    RE2::PartialMatch(str, re, &m1, &m2, &m3, &m4);
  }
  return 0;
}
