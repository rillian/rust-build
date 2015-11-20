#!/bin/bash -vex

set -x -e

: RUST_RESPOSITORY  ${RUST_REPOSITORY:=https://github.com/rust-lang/rust}
: RUST_BASE_REPOSITORY ${RUST_BASE_REPOSITORY:=${RUST_REPOSITORY}}
: RUST_HEAD_REPOSITORY ${RUST_HEAD_REPOSITORY:=${RUST_REPOSITORY}}
: RUST_HEAD_REV        ${RUST_HEAD_REV:=stable}
: RUST_HEAD_REF        ${RUST_HEAD_REV:=stable}

: WORKSPACE                     ${WORKSPACE:=/home/worker/workspace}

set -v

# Configure and build rust.
pushd ${WORKSPACE}/rust
./configure --prefix=${WORKSPACE}/rustc --enable-rpath
make
make install
popd

# Package the toolchain for upload.
pushd ${WORKSPACE}
tar cvJf rustc.tar.xz rustc/*
tooltool add --visibility=public --unpack rustc.tar.xz
popd
