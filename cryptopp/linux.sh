#!/bin/bash
set -e

export MAKEFLAGS="-j$(nproc)"

scriptdir=$(dirname $(readlink -f $0))

# add ppas
apt-get -qq update
apt-get -qq install software-properties-common
add-apt-repository -y ppa:ubuntu-toolchain-r/test

# install build deps
apt-get -qq update
apt-get -qq install --no-install-recommends make g++ git ca-certificates curl python3 gcc-6 g++-6

# test gcc
gcc-6 --version
g++-6 --version

# get sources and start building
outDir=$scriptdir/cryptopp
cd $scriptdir
mkdir cryptopp
mkdir build
pushd build

curl -Lo "./$CRYPTOPP_NAME.tar.gz" "https://github.com/weidai11/cryptopp/archive/$CRYPTOPP_NAME.tar.gz"
echo "$CRYPTOPP_SHA512SUM $CRYPTOPP_NAME.tar.gz" | sha512sum --check -

tar -xf "$CRYPTOPP_NAME.tar.gz"

cd cryptopp-$CRYPTOPP_NAME
make static shared CXX=g++-6 CC=gcc-6
make install PREFIX=$outDir

popd
