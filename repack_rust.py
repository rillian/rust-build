#!/bin/env python
'''
This script downloads and repacks official rust language builds
with the necessary tool and target support for the Firefox
build environment.
'''

import requests
import toml

def repack(channel='stable'):
  url = 'https://static.rust-lang.org/dist/channel-rust-' + channel + '.toml'
  req = requests.get(url)
  req.raise_for_status()
  manifest = toml.loads(req.content)
  if manifest['manifest-version'] != '2':
    print('ERROR: unrecognized manifest version %s.' % manifest['manifest-version'])
    return
  print('manifest for rust %s as of %s.' % (channel, manifest['date']))
  host='x86_64-apple-darwin'
  rustc_version = manifest['pkg']['rustc']['version']
  rustc = manifest['pkg']['rustc']['target'][host]
  if rustc['available']:
    print('rustc %s\n  %s\n  %s' % (rustc_version, rustc['url'], rustc['hash']))
  cargo_version = manifest['pkg']['cargo']['version']
  cargo = manifest['pkg']['cargo']['target'][host]
  if cargo['available']:
    print('cargo %s\n  %s\n  %s' % (cargo_version, cargo['url'], cargo['hash']))
  std_version = manifest['pkg']['rust-std']['version']
  std = manifest['pkg']['rust-std']['target'][host]
  if std['available']:
    print('rust-std %s\n  %s\n  %s' % (std_version, std['url'], std['hash']))

if __name__ == '__main__':
    repack()

'''
fetch() {
  echo "Fetching $1..."
  curl -Os ${RUST_URL}${1}.asc
  curl -Os ${RUST_URL}${1}
  curl -Os ${RUST_URL}${1}.sha256
  curl -Os ${RUST_URL}${1}.asc.sha256
}

verify() {
  echo "Verifying $1..."
  shasum -c ${1}.sha256
  shasum -c ${1}.asc.sha256
  gpg --verify ${1}.asc ${1}
  keybase verify ${1}.asc
}

fetch_rustc() {
  arch=$1
  echo "Retrieving rustc build for $arch..."
  pkg=$(cat ${IDX} | grep ^rustc | grep $arch)
  test -n "${pkg}" || die "No rustc build for $arch in the manifest."
  test 1 == $(echo ${pkg} | wc -w) ||
    die "Multiple rustc builds for $arch in the manifest."
  fetch ${pkg}
  verify ${pkg}
}

fetch_std() {
  echo "Retrieving rust-std builds for:"
  for arch in $@; do
    echo "  $arch"
  done
  for arch in $@; do
    pkg=$(cat ${IDX} | grep rust-std | grep $arch)
    test -n "${pkg}" || die "No rust-std builds for $arch in the manifest."
    test 1 == $(echo ${pkg} | wc -w) ||
      die "Multiple rust-std builds for $arch in the manifest."
    fetch ${pkg}
    verify ${pkg}
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
    file ${TARGET}/bin/rustc
    ${TARGET}/bin/rustc --version
  elif test -x ${TARGET}/bin/rustc.exe; then
    file ${TARGET}/bin/rustc.exe
    ${TARGET}/bin/rustc.exe --version
  else
    die "ERROR: Couldn't fine rustc executable"
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

mac64="x86_64-apple-darwin"
mac32="i686-apple-darwin"

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
repack_linux64() {
  fetch_rustc $linux64
  fetch_std $linux64 $linux32

  rm -rf ${TARGET}

  install_rustc $linux64
  install_std $linux64 $linux32

  tar cJf rustc-$linux64-repack.tar.xz ${TARGET}/*
  check ${TARGET}
}

# Repack the win64 builds.
repack_win64() {
  fetch_rustc $win64
  fetch_std $win64

  rm -rf ${TARGET}

  install_rustc $win64
  install_std $win64

  tar cjf rustc-$win64-repack.tar.bz2 ${TARGET}/*
  check ${TARGET}
}

# Repack the win32 builds.
repack_win32() {
  fetch_rustc $win32
  fetch_std $win32

  rm -rf ${TARGET}

  install_rustc $win32
  install_std $win32

  tar cjf rustc-$win32-repack.tar.bz2 ${TARGET}/*
  check ${TARGET}
}

# Repack the mac builds.
repack_mac() {
  fetch_rustc $mac64
  fetch_std $mac64 $mac32

  rm -rf ${TARGET}

  install_rustc $mac64
  install_std $mac64 $mac32

  tar cjf rustc-mac-repack.tar.bz2 ${TARGET}/*
  check ${TARGET}
}

# Repack mac cross build.
repack_mac_cross() {
  fetch_rustc $linux64
  fetch_std $linux64

  rm -rf ${TARGET}

  install_rustc $linux64
  install_std $linux64 $mac64 $mac32

  tar cJf rustc-mac-cross-repack.tar.xz ${TARGET}/*
  check ${TARGET}
}

repack_win32
repack_win64
repack_linux64
repack_mac
repack_mac_cross

rm -rf ${TARGET}
'''