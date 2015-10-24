// Copyright 2015 Google Inc. All Rights Reserved.
// Licensed under the Apache License, Version 2.0 (the "License");

#include <string>
#include "re2/re2.h"
#include "util/logging.h"

using std::string;

void Test(const string &str, const string &pat, const RE2::Options &opt) {
  RE2 re(pat, opt);
  if (re.ok()) {
    string m1, m2, m3, m4;
    int i1, i2, i3;
    if (re.NumberOfCapturingGroups() == 0) {
      RE2::FullMatch(str, re);
      RE2::PartialMatch(str, re);
    } else if (re.NumberOfCapturingGroups() == 1) {
      RE2::FullMatch(str, re, &m1);
      RE2::PartialMatch(str, re, &i1);
    } else if (re.NumberOfCapturingGroups() == 2) {
      RE2::FullMatch(str, re, &i1, &i2);
      RE2::PartialMatch(str, re, &m1, &m2);
    }
    re2::StringPiece input(str);
    RE2::Consume(&input, re, &m1);
    RE2::FindAndConsume(&input, re, &i1);
    string tmp1(str);
    RE2::Replace(&tmp1, re, "zz");
    string tmp2(str);
    RE2::GlobalReplace(&tmp2, re, "xx");
    RE2::QuoteMeta(re2::StringPiece(pat));
  }
}


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
  const char *beg = reinterpret_cast<const char*>(data);
  {
    string pat(beg, size);
    string str(beg, size);
    Test(str, pat, opt);
  }
  if (size >= 3) {
    string pat(beg, size / 3);
    string str(beg + size / 3, size - size / 3);
    Test(str, pat, opt);
  }
  return 0;
}
