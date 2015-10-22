FROM ubuntu:14.04

MAINTAINER aizatsky@google.com

RUN apt-get update
RUN apt-get install -y build-essential python golang
RUN apt-get install -y cmake ninja-build autoconf automake autotools-dev libtool coreutils 
RUN apt-get install -y git subversion

RUN mkdir -p /src
RUN mkdir -p /src/scripts

RUN mkdir -p /work
VOLUME /work
