#!/bin/bash
set -e

export MAKEFLAGS="-j$(nproc)"

NAME=CRYPTOPP_${CRYPTOPP_VERSION}
SHA512SUM=82e9a51080ace2734bfe4ba932c31e6a963cb20b570f0fea2fbe9ceccb887c8afecb36cde91c46ac6fea1357fdff6320ab2535b3f0aa48424acdd2cd9dd2e880

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
outDir=$(pwd)/cryptopp
mkdir $outDir
mkdir build
pushd build

curl -Lo "./$NAME.tar.gz" "https://github.com/weidai11/cryptopp/archive/$NAME.tar.gz"
echo "$SHA512SUM $NAME.tar.gz" | sha512sum --check -

tar -xf "$NAME.tar.gz"

cd cryptopp-$NAME
make static shared CXX=g++-6 CC=gcc-6
make install PREFIX=$outDir

popd

# pack up for deployment
tar cJf cryptopp_${CRYPTOPP_VERSION}_linux.tar.xz cryptopp
