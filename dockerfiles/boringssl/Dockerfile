FROM libfuzzer/base-fuzzer

MAINTAINER aizatsky@google.com

WORKDIR /src
RUN git clone --depth 1 https://boringssl.googlesource.com/boringssl
ADD fuzzer.cc /src/boringssl/
ADD server.key /src/boringssl/
ADD server.pem /src/boringssl/

VOLUME /src/boringssl

RUN mkdir -p /work/boringssl
