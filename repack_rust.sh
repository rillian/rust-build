#!/bin/bash -vex

set -x -e

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

set -v

x32="i686-unknown-linux-gnu"
x64="x86_64-unknown-linux-gnu"
arm="arm-linux-androideabi"

# Fetch the manifest
IDX=channel-rustc-${RUST_CHANNEL}

fetch ${IDX}
verify ${IDX}

for arch in $x32 $x64; do
  for pkg in $(cat ${IDX} | grep ^rustc | grep $arch); do
    fetch ${pkg}
    verify ${pkg}
  done
  for pkg in $(cat ${IDX} | grep rust-std | grep $arch); do
    fetch ${pkg}
    verify ${pkg}
  done
done
  
# FIXME: generalize this to use the arch and manifest lists.
TARGET=rustc
INSTALL_OPTS="--prefix=${PWD}/${TARGET} --disable-ldconfig"
rm -rf ${TARGET}

# Install rustc.
tar xf rustc-beta-x86_64-unknown-linux-gnu.tar.gz
rustc-beta-x86_64-unknown-linux-gnu/install.sh ${INSTALL_OPTS}
rm -rf rustc-beta-x86_64-unknown-linux-gnu

# Install standard libraries for targets we need.
tar xf rust-std-beta-x86_64-unknown-linux-gnu.tar.gz
rust-std-beta-x86_64-unknown-linux-gnu/install.sh ${INSTALL_OPTS}
rm -rf rust-std-beta-x86_64-unknown-linux-gnu
tar xf rust-std-beta-i686-unknown-linux-gnu.tar.gz
rust-std-beta-i686-unknown-linux-gnu/install.sh ${INSTALL_OPTS}
rm -rf rust-std-beta-i686-unknown-linux-gnu

${TARGET}/bin/rustc --version
echo "Installed components:"
cat ${TARGET}/lib/rustlib/components
echo

# Repack for distribution.
tar cvJf rustc.tar.xz ${TARGET}/*
