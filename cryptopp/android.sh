#!/bin/bash
set -e
# $1 android abi (armv7a, x86)

export MAKEFLAGS="-j$(nproc)"
export ANDROID_HOME=$HOME/android-sdk/
export ANDROID_NDK=$HOME/android-sdk/ndk-bundle/

ABI=$1
scriptdir=$(dirname $(readlink -f $0))

# install build deps
apt-get -qq update
apt-get -qq install --no-install-recommends make git ca-certificates curl python3 openjdk-8-jdk unzip

# android skd/ndk
curl -Lo /tmp/android-sdk.zip https://dl.google.com/android/repository/sdk-tools-linux-3859397.zip
mkdir $ANDROID_HOME
unzip -qq /tmp/android-sdk.zip -d $ANDROID_HOME
echo y | $ANDROID_HOME/tools/bin/sdkmanager --update > /dev/null
echo y | $ANDROID_HOME/tools/bin/sdkmanager "ndk-bundle" > /dev/null

# setup and build
export ANDROID_SDK_ROOT=$ANDROID_HOME
export ANDROID_NDK_ROOT=$ANDROID_NDK
export ABI_NR=16
export AOSP_API="android-$ABI_NR"

if [[ "$ABI" == "armv7a" ]]; then
	ABI_INC=arm-linux-androideabi
fi
if [[ "$ABI" == "x86" ]]; then
	ABI_INC=i686-linux-android
fi

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
set +e
source setenv-android.sh $ABI gnu
set -e
export AOSP_STL_INC="$ANDROID_NDK_ROOT/sysroot/usr/include/$ABI_INC -I$AOSP_STL_INC -I$ANDROID_NDK_ROOT/sysroot/usr/include/"
export CXXFLAGS="-D__ANDROID_API__=$ABI_NR"
make -f GNUmakefile-cross static shared
make -f GNUmakefile-cross install PREFIX=$outDir

popd
