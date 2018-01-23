#!/bin/bash
set -e

export MAKEFLAGS="-j$(sysctl -n hw.ncpu)"

scriptdir=$(dirname $(greadlink -f $0))

# brew
brew update
brew upgrade coreutils || brew install coreutils

# get sources and start building
outDir=$scriptdir/cryptopp
cd $scriptdir
mkdir cryptopp
mkdir build
pushd build

curl -Lo "./$CRYPTOPP_NAME.tar.gz" "https://github.com/weidai11/cryptopp/archive/$CRYPTOPP_NAME.tar.gz"
echo "$CRYPTOPP_SHA512SUM $CRYPTOPP_NAME.tar.gz" | gsha512sum --check -

tar -xf "$CRYPTOPP_NAME.tar.gz"

cd cryptopp-$CRYPTOPP_NAME
set +e
source ./setenv-ios.sh
set -e
make -f GNUmakefile-cross static
make -f GNUmakefile-cross install PREFIX=$outDir

popd
