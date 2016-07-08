#!/bin/bash -vex

set -x -e

# Inputs, with defaults

: RUST_REPOSITORY ${RUST_REPOSITORY:=https://github.com/rust-lang/cargo}
: RUST_BRANCH     ${RUST_BRANCH:=master}

: WORKSPACE       ${WORKSPACE:=/home/worker}

set -v

# Check out rust sources
git clone --recursive $RUST_REPOSITORY -b $RUST_BRANCH ${WORKSPACE}/cargo

# Report version
VERSION=$(git -C ${WORKSPACE}/cargo describe --tags --dirty)
COMMIT=$(git -C ${WORKSPACE}/cargo rev-parse HEAD)
echo "cargo ${VERSION} (commit ${COMMIT})" | tee cargo-version
