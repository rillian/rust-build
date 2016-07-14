#!/bin/env python
'''
This script downloads and repacks official rust language builds
with the necessary tool and target support for the Firefox
build environment.
'''

import requests
import toml
import os

def fetch_file(url):
  '''Download a file from the given url if it's not already present.'''
  filename = os.path.basename(url)
  if os.path.exists(filename):
    return
  r = requests.get(url, stream=True)
  r.raise_for_status()
  with open(filename, 'wb') as fd:
    for chunk in r.iter_content(4096):
      fd.write(chunk)

def fetch(url):
  '''Download and verify a package url.'''
  base = os.path.basename(url)
  print('Fetching %s...' % base)
  fetch_file(url + '.asc')
  fetch_file(url)
  fetch_file(url + '.sha256')
  fetch_file(url + '.asc.sha256')
  print('Verifying %s...' % base)
  # TODO: check for verification failure.
  os.system('shasum -c %s.sha256' % base)
  os.system('shasum -c %s.asc.sha256' % base)
  os.system('gpg --verify %s.asc %s' % (base, base))
  os.system('keybase verify %s.asc' % base)

def install(filename, target):
  '''Run a package's installer script against the given target directory.'''
  print(' Unpacking %s...' % filename)
  os.system('tar xf ' + filename)
  basename = filename.split('.tar')[0]
  print(' Installing %s...' % basename)
  install_opts = '--prefix=${PWD}/%s --disable-ldconfig' % target
  os.system('%s/install.sh %s' % (basename, install_opts))
  print(' Cleaning %s...' % basename)
  os.system('rm -rf %s' % basename)

def package(manifest, pkg, target):
  '''Pull out the package dict for a particular package and target
  from the given manifest.'''
  version = manifest['pkg'][pkg]['version']
  info = manifest['pkg'][pkg]['target'][target]
  return (version, info)

def repack(host, targets, channel='stable'):
  url = 'https://static.rust-lang.org/dist/channel-rust-' + channel + '.toml'
  req = requests.get(url)
  req.raise_for_status()
  manifest = toml.loads(req.content)
  if manifest['manifest-version'] != '2':
    print('ERROR: unrecognized manifest version %s.' % manifest['manifest-version'])
    return
  print('Using manifest for rust %s as of %s.' % (channel, manifest['date']))
  rustc_version, rustc = package(manifest, 'rustc', host)
  if rustc['available']:
    print('rustc %s\n  %s\n  %s' % (rustc_version, rustc['url'], rustc['hash']))
    fetch(rustc['url'])
  cargo_version, cargo = package(manifest, 'cargo', host)
  if cargo['available']:
    print('cargo %s\n  %s\n  %s' % (cargo_version, cargo['url'], cargo['hash']))
    fetch(cargo['url'])
  stds = []
  for target in targets:
      version, info = package(manifest, 'rust-std', target)
      if info['available']:
        print('rust-std %s\n  %s\n  %s' % (version, info['url'], info['hash']))
        fetch(info['url'])
        stds.append(info)
  print('Installing packages...')
  tar_basename = 'rustc-%s-repack' % host
  install_dir = 'rustc'
  os.system('rm -rf %s' % install_dir)
  install(os.path.basename(rustc['url']), install_dir)
  install(os.path.basename(cargo['url']), install_dir)
  for std in stds:
    install(os.path.basename(std['url']), install_dir)
  print('Tarring %s...' % tar_basename)
  os.system('tar cjf %s.tar.bz2 %s/*' % (tar_basename, install_dir))
  os.system('rm -rf %s' % install_dir)

# rust platform triples
android="arm-linux-androideabi"
linux64="x86_64-unknown-linux-gnu"
linux32="i686-unknown-linux-gnu"
mac64="x86_64-apple-darwin"
mac32="i686-apple-darwin"
win64="x86_64-pc-windows-msvc"
win32="i686-pc-windows-msvc"

if __name__ == '__main__':
  repack(mac64, [mac64, mac32])
  repack(win32, [win32])
  repack(win64, [win64])
  repack(linux64, [linux64, linux32])

'''
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
