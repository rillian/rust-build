#!/bin/bash

set -x -e

: WORKSPACE ${WORKSPACE:=/home/worker/workspace}

CORES=$(nproc || grep -c ^processor /proc/cpuinfo || sysctl -n hw.ncpu)

set -v

pushd ${WORKSPACE}
sha256sum -c SHA256SUMS.txt

# Configure and build.
tar xf gmp-6.1.0.tar.xz
pushd gmp-6.1.0
./configure
make -j ${CORES}
make install
popd

pushd mpfr-3.1.3
./configure --with-mpd=/usr/local
make -j ${CORES}
make install
popd

pushd mpc-1.0.3
./configure --with-gmp=/usr/local --with-mpfr=/usr/local
make -j ${CORES}
make install
popd

pushd ${WORKSPACE}/gcc
./configure ./configure --with-gmp=/usr/local --with-mpfr=/usr/local --with-mpc=/usr/local --disable-multilib
# parallel make takes several tries
make -j ${CORES}
make install
popd
