#!/bin/bash -vex

set -x -e

# Inputs, with defaults
#
# If the revision is not in the standard repo for the codebase,
# specify *_BASE_REPO as the canonical repo to clone and *_HEAD_REPO
# as the repo containing the desired revision.
#
# For Mercurial clones, only *_HEAD_REV is required; for Git
# clones, specify the branch name to fetch as *_HEAD_REF and
# the desired sha1 as *_HEAD_REV.

: RUST_RESPOSITORY  ${RUST_REPOSITORY:=https://github.com/rust-lang/rust}
: RUST_BASE_REPOSITORY ${RUST_BASE_REPOSITORY:=${RUST_REPOSITORY}}
: RUST_HEAD_REPOSITORY ${RUST_HEAD_REPOSITORY:=${RUST_REPOSITORY}}
: RUST_HEAD_REV        ${RUST_HEAD_REV:=stable}
: RUST_HEAD_REF        ${RUST_HEAD_REF:=${RUST_HEAD_REV}}

: WORKSPACE                     ${WORKSPACE:=/home/worker/workspace}

set -v

# Check out rust sources
#tc-vcs checkout ${WORKSPACE}/rust $RUST_BASE_REPOSITORY $RUST_HEAD_REPOSITORY $RUST_HEAD_REV $RUST_HEAD_REF
git clone $RUST_HEAD_REPOSITORY ${WORKSPACE}/rust
pushd ${WORKSPACE}/rust
git checkout ${RUST_HEAD_REF}
popd
