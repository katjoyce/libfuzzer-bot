This page describes an [experimental fuzzer bot](http://104.197.106.156/) for [Ninja](https://github.com/martine/ninja).

The bot uses [libFuzzer](http://llvm.org/docs/LibFuzzer.html) and
[AddressSanitizer](http://clang.llvm.org/docs/AddressSanitizer.html) to find existing
bugs in Ninja and possible new regressions.

The test corpus is 100% synthesised from scratch.
