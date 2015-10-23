This page describes an [experimental fuzzer bot](http://104.197.8.28/) for [RE2](https://github.com/google/re2).

The bot uses [libFuzzer](http://llvm.org/docs/LibFuzzer.html) and
[AddressSanitizer](http://clang.llvm.org/docs/AddressSanitizer.html) to find existing
bugs in RE2 and possible new regressions.
Currently, the [target function](./re2_fuzzer.cc) is *very* simple, we'll be extending it in future.

The test corpus is 100% synthesised from scratch.
