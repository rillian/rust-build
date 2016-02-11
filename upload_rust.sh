#!/bin/bash -vex

set -x -e

: WORKSPACE ${WORKSPACE:=/home/worker}

CORES=$(nproc || grep -c ^processor /proc/cpuinfo || sysctl -n hw.ncpu)

set -v

# Upload artifacts packaged by the build script.
pushd ${WORKSPACE}
if test -n "$TASK_ID";
  # If we're running on task cluster, use the upload-capable tunnel.
  TOOLTOOL_OPTS="--url=http://relengapi/tooltool/"
fi
MESSAGE="Taskcluster upload ${TASK_ID}/${RUN_ID} $0"
tar cvJf rustc.tar.xz rustc/*
/build/tooltool.py upload ${TOOLTOOL_OPTS} --msg=${MESSAGE}
popd
