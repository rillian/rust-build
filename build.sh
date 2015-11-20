#!/bin/bash -vex

set -x -e

: RUST_RESPOSITORY  ${RUST_REPOSITORY:=https://github.com/rust-lang/rust}
: RUST_BASE_REPOSITORY ${RUST_BASE_REPOSITORY:=${RUST_REPOSITORY}}
: RUST_HEAD_REPOSITORY ${RUST_HEAD_REPOSITORY:=${RUST_REPOSITORY}}
: RUST_HEAD_REV        ${RUST_HEAD_REV:=stable}
: RUST_HEAD_REF        ${RUST_HEAD_REV:=stable}

: WORKSPACE                     ${WORKSPACE:=/home/worker/workspace}

CORES=$(nproc || grep -c ^processor /proc/cpuinfo || sysctl -n hw.ncpu)

set -v

# Configure and build rust.
pushd ${WORKSPACE}/rust
./configure --prefix=${WORKSPACE}/rustc --enable-rpath
make -j ${CORES}
make install
popd

# Package the toolchain for upload.
pushd ${WORKSPACE}
tar cvJf rustc.tar.xz rustc/*
/builds/tooltool.py add --visibility=public rustc.tar.xz
popd
