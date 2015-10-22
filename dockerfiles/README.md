# Dockerized LibFuzzer Tests

This folder contains files used to build self-contained LibFuzzer tests
for a variety of open source projects. The goal is to provide 0-friction
environment to run tests, create new fuzzers and experiment with LibFuzzer
development.


## Prerequisites

The only requirement is to have docker running on the system.
Check [https://docs.docker.com/] for docker installation guide.

## Available Projects
* boringssl
* freetype2
* pcre2

## Running Tests
*Operations with all tests are similar. Boringssl would be used for demonstration.*

To compile everything and run library tests do:
```
docker run libfuzzer/boringssl
```

Most likely you would like to control tests within terminal. Add `-ti` docker option for that:
```
docker run -ti libfuzzer/boringssl
```

### Reusing compilation artifacts between runs
To reuse compilation artifacts bewteen run you should mount a local
directory into container's `/work` path:

```
docker run -v /tmp/work:/work libfuzzer/boringssl
```

### Environment variables
A set of environment variables controls test compilation and execution mode.
Environment variables could be specified using `-e` docker option:

```
docker run -e SANITIZER_OPTIONS="-fsanitize=memory"
```

Variable    | Default | Description
----------- | ------- | -----
SANITIZER_OPTIONS | -fsanitize=address | Compiler's sanitizer options.
COVERAGE_OPTIONS | -fsanitize-coverage=edge,indirect-calls,8bit-counters,trace-cmp | Compiler's coverage options.
FUZZER_OPTIONS | -use_traces=1 -max_total_time=120 | Fuzzer's running options
ASAN_OPTIONS | quarantine_size_mb=10:symbolize=1:abort_on_error=1:handle_abort=1 | Asan's running options

### Using custom LLVM sources
When working on LLVM/LibFuzzer, you can mount your local source tree into container's `/src/llvm`. It would be used instead of image sources.

```
docker run -v ~/src/lvvm:/src/llvm libfuzzer/boringssl
```

### Using custom library sources
While working on a library itself, you can mount your local source tree into
containers `/src/<library_name>`:

```
docker run -v ~/src/boringssl:/src/boringssl libfuzzer/boringssl
```

## Adding New Projects
To create image for a new project, follow these instructions: [base-fuzzer/README.md]
