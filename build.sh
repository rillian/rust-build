#!/bin/bash -vex

set -x -e

: WORKSPACE ${WORKSPACE:=/home/worker}

CORES=$(nproc || grep -c ^processor /proc/cpuinfo || sysctl -n hw.ncpu)

set -v

# Configure and build rust.
pushd ${WORKSPACE}/rust
./configure --prefix=${WORKSPACE}/rustc --enable-rpath --disable-docs
make -j ${CORES}
make install
popd

# Package the toolchain for upload.
pushd ${WORKSPACE}
tar cvJf rustc.tar.xz rustc/*
/builds/tooltool.py add --visibility=public rustc.tar.xz
popd
