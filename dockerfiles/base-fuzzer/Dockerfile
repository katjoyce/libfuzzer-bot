FROM libfuzzer/base-clang

MAINTAINER aizatsky@google.com

ONBUILD ADD build.sh /src/scripts/
ONBUILD ADD run.sh /src/scripts/

ENV SANITIZER_OPTIONS="-fsanitize=address"
ENV COVERAGE_OPTIONS="-fsanitize-coverage=edge,indirect-calls,8bit-counters,trace-cmp"
ENV CFLAGS="-g"
ENV CXXFLAGS="-g"
ENV BASH_FLAGS="-e"

ENV FUZZER_OPTIONS="-use_traces=1 -max_total_time=120"
# detect_leaks - by default ptrace doesn't work within container. Use:
#                --cap-add SYS_PTRACE --security-opt apparmor:unconfined
#                arguments for docker run to enable it.
# quarantine_size_mb - make asan less memory hungry
ENV ASAN_OPTIONS="detect_leaks=0:quarantine_size_mb=10:symbolize=1:abort_on_error=1:handle_abort=1"

WORKDIR /src/scripts/
CMD bash $BASH_FLAGS /src/scripts/driver.sh

ADD driver.sh /src/scripts/
