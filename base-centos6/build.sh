#!/bin/bash -vex

set -x -e

: WORKSPACE ${WORKSPACE:=/home/worker/workspace}

CORES=$(nproc || grep -c ^processor /proc/cpuinfo || sysctl -n hw.ncpu)

set -v

# Configure and build rust.
pushd ${WORKSPACE}/gcc
./configure
make -j ${CORES}
make install
popd
