#!/bin/bash -vex

set -e

# Set verbose options on taskcluster for logging.
test -n "$TASK_ID" && set -x

# Inputs, with defaults

: RUST_URL        ${RUST_URL:=https://static.rust-lang.org/dist/}
: RUST_CHANNEL    ${RUST_CHANNEL:=stable}

: WORKSPACE       ${WORKSPACE:=/home/worker}

fetch() {
  echo "fetching $1..."
  curl -Os ${RUST_URL}${1}.asc
  curl -Os ${RUST_URL}${1}
  curl -Os ${RUST_URL}${1}.sha256
  curl -Os ${RUST_URL}${1}.asc.sha256
}

verify() {
  echo "verifying $1..."
  shasum -c ${1}.sha256
  shasum -c ${1}.asc.sha256
  gpg --verify ${1}.asc ${1}
  keybase verify ${1}.asc
}

fetch_rustc() {
  arch=$1
  echo "Retrieving rustc build for $arch..."
  for pkg in $(cat ${IDX} | grep ^rustc | grep $arch); do
    fetch ${pkg}
    verify ${pkg}
  done
}

fetch_std() {
  echo "Retrieving rust-std builds for $@"
  for arch in $@; do
    for pkg in $(cat ${IDX} | grep rust-std | grep $arch); do
      fetch ${pkg}
      verify ${pkg}
    done
  done
}

install_rustc() {
  pkg=$(cat ${IDX} | grep ^rustc | grep $1)
  base=${pkg%%.tar.*}
  echo "Installing $base..."
  tar xf ${pkg}
  ${base}/install.sh ${INSTALL_OPTS}
  rm -rf ${base}
}

install_std() {
  for arch in $@; do
    for pkg in $(cat ${IDX} | grep rust-std | grep $arch); do
      base=${pkg%%.tar.*}
      echo "Installing $base..."
      tar xf ${pkg}
      ${base}/install.sh ${INSTALL_OPTS}
      rm -rf ${base}
    done
  done
}

check() {
  if test -x ${TARGET}/bin/rustc; then
    ${TARGET}/bin/rustc --version
  elif test -x ${TARGET}/bin/rustc.exe; then
    ${TARGET}/bin/rustc.exe --version
  else
    echo "ERROR: Couldn't fine rustc executable"
    exit 1
  fi
  echo "Installed components:"
  for component in $(cat ${TARGET}/lib/rustlib/components); do
    echo "  $component"
  done
  echo
}

test -n "$TASK_ID" && set -v

linux64="x86_64-unknown-linux-gnu"
linux32="i686-unknown-linux-gnu"

android="arm-linux-androideabi"

win64="x86_64-pc-windows-msvc"
win32="i686-pc-windows-msvc"
win32_i586="i586-pc-windows-msvc"

# Fetch the manifest

IDX=channel-rustc-${RUST_CHANNEL}

fetch ${IDX}
verify ${IDX}

TARGET=rustc
INSTALL_OPTS="--prefix=${PWD}/${TARGET} --disable-ldconfig"

# Repack the linux64 builds.

fetch_rustc $linux64
fetch_std $linux64 $linux32

rm -rf ${TARGET}

install_rustc $linux64
install_std $linux64 $linux32

tar cJf rustc-$linux64-repack.tar.xz ${TARGET}/*
check ${TARGET}

# Repack the win64 builds.

fetch_rustc $win64
fetch_std $win64

rm -rf ${TARGET}

install_rustc $win64
install_std $win64

tar cjf rustc-$win64-repack.tar.bz2 ${TARGET}/*
check ${TARGET}

# Repack the win32 builds.

fetch_rustc $win32
fetch_std $win32 $win32_i586

rm -rf ${TARGET}

install_rustc $win32
install_std $win32 $win32_i586

tar cjf rustc-$win32-repack.tar.bz2 ${TARGET}/*
check ${TARGET}

rm -rf ${TARGET}
