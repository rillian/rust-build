#!/bin/bash

set -x -e

: WORKSPACE ${WORKSPACE:=/home/worker/workspace}

CORES=$(nproc || grep -c ^processor /proc/cpuinfo || sysctl -n hw.ncpu)

set -v

pushd ${WORKSPACE}
sha256sum -c SHA256SUMS.txt

# Configure and build.
pushd ${WORKSPACE}/gcc-4.8.5
./configure ./configure --enable-languages=c,c++ --disable-multilib
make -j ${CORES}
make install
popd

pushd ${WORKSPACE}/Python-2.7.10
./configure
make -j ${CORES}
make install
popd
