#!/bin/bash -vex

set -x -e

# Inputs, with defaults

: REPOSITORY ${REPOSITORY:=https://gcc.gnu.org/git/gcc.git}
#: REPOSITORY ${REPOSITORY:=https://github.com/gcc-mirror/gcc}

: BRANCH     ${BRANCH:=gcc-5_2_0-release}

: WORKSPACE  ${WORKSPACE:=/home/worker/workspace}

set -v

# Check out rust sources
git clone $REPOSITORY -b $BRANCH ${WORKSPACE}/gcc
