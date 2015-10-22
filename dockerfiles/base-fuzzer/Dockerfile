FROM libfuzzer/base-clang

MAINTAINER aizatsky@google.com

ONBUILD ADD build.sh /src/scripts/
ONBUILD ADD run.sh /src/scripts/

ENV SANITIZER_OPTIONS="-fsanitize=address"
ENV COVERAGE_OPTIONS="-fsanitize-coverage=edge,indirect-calls,8bit-counters,trace-cmp"
ENV CC_OPTIONS="-g"

ENV FUZZER_OPTIONS="-use_traces=1 -max_total_time=120"
# make asan less memory hungry
ENV ASAN_OPTIONS="quarantine_size_mb=10:symbolize=1:abort_on_error=1:handle_abort=1"

CMD bash -x -e /src/scripts/driver.sh

ADD driver.sh /src/scripts/
