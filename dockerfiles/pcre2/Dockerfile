FROM libfuzzer/base-fuzzer

MAINTAINER aizatsky@google.com

RUN cd /src && svn co svn://vcs.exim.org/pcre2/code/trunk pcre2
ADD pcre2_fuzzer.cc /src/pcre2/

VOLUME /src/pcre2
