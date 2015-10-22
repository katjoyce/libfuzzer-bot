FROM libfuzzer/base-fuzzer

MAINTAINER aizatsky@google.com

WORKDIR /src
RUN git clone --depth 1 git://git.sv.nongnu.org/freetype/freetype2.git

VOLUME /src/freetype2
