#!/bin/bash

set -x -e

# Inputs, with defaults

: REPOSITORY ${REPOSITORY:=https://gcc.gnu.org/git/gcc.git}
#: REPOSITORY ${REPOSITORY:=https://github.com/gcc-mirror/gcc}

: BRANCH     ${BRANCH:=gcc-5_2_0-release}

: WORKSPACE  ${WORKSPACE:=/home/worker/workspace}

set -v

# Check out rust sources
#git clone $REPOSITORY -b $BRANCH ${WORKSPACE}/gcc

# Download release
VERSION=5.2.0
mkdir -p ${WORKSPACE}
pushd ${WORKSPACE}
# gcc
gpg --keyserver hkp://keys.gnupg.net --recv-keys 0xFC26A641
curl -Os http://ftp.gnu.org/gnu/gcc/gcc-${VERSION}/gcc-${VERSION}.tar.bz2.sig
curl -Os http://gcc.skazkaforyou.com/releases/gcc-${VERSION}/gcc-${VERSION}.tar.bz2
gpg --verify gcc-${VERSION}.tar.bz2.sig
tar xf gcc-${VERSION}.tar.bz2

# deps

#curl -Os ftp://gcc.gnu.org/pub/gcc/infrastructure/mpc-0.8.1.tar.gz
#curl -Os ftp://gcc.gnu.org/pub/gcc/infrastructure/mpfr-2.4.2.tar.bz2
#curl -Os ftp://gcc.gnu.org/pub/gcc/infrastructure/gmp-4.3.2.tar.bz2

GMP_VERSION=6.1.0
gpg --keyserver hkp://keys.gnupg.net --recv-keys 0xDDEF6956501441DF
curl -Os https://gmplib.org/download/gmp/gmp-${GMP_VERSION}.tar.xz.sig
curl -Os https://gmplib.org/download/gmp/gmp-${GMP_VERSION}.tar.xz
gpg --verify gmp-${GMP_VERSION}.tar.xz.sig
tar xf gmp-${GMP_VERSION}.tar.xz

MPFR_VERSION=3.1.3
gpg --keyserver hkp://keys.gnupg.net --recv-keys 0x980C197698C3739D
curl -Os http://www.mpfr.org/mpfr-current/mpfr-${MPFR_VERSION}.tar.xz.asc
curl -Os http://www.mpfr.org/mpfr-current/mpfr-${MPFR_VERSION}.tar.xz
gpg --verify mpfr-${MPFR_VERSION}.tar.xz.asc
tar xf mpfr-${MPFR_VERSION}.tar.xz

MPC_VERSION=1.0.3
gpg --keyserver hkp://keys.gnupg.net --recv-keys 0xF7D5C9BF765C61E3
curl -Os ftp://ftp.gnu.org/gnu/mpc/mpc-${MPC_VERSION}.tar.gz.sig
curl -Os ftp://ftp.gnu.org/gnu/mpc/mpc-${MPC_VERSION}.tar.gz
gpg --verify mpc-${MPC_VERSION}.tar.gz.sig
tar xf mpc-${MPC_VERSION}.tar.gz
popd
