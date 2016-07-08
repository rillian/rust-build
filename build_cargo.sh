#!/bin/bash -vex

set -x -e

: WORKSPACE ${WORKSPACE:=/home/worker}

set -v

# Configure and build cargo.

pushd ${WORKSPACE}/cargo
./configure --prefix=${WORKSPACE}/rustc --local-rust-root=${WORKSPACE}/rustc
make
make install
popd
