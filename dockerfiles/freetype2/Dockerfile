FROM libfuzzer/base-fuzzer

MAINTAINER aizatsky@google.com

RUN apt-get install -y libarchive-dev

WORKDIR /src
RUN git clone --depth 1 git://git.sv.nongnu.org/freetype/freetype2.git

ENV FUZZERS="/work/freetype2/freetype2_fuzzer"

VOLUME /src/freetype2
