#!/bin/bash
set -e

export XZ_OPT=-9
export MAKEFLAGS="-j$(nproc)"
export ANDROID_HOME=$HOME/android-sdk/
export ANDROID_NDK=$HOME/android-sdk/ndk-bundle/

scriptdir=$(dirname $(readlink -f $0))

sudo apt-get -qq update
sudo apt-get -qq install --no-install-recommends make git ca-certificates curl python3 openjdk-8-jdk unzip

# android skd/ndk
curl -Lo /tmp/android-sdk.zip https://dl.google.com/android/repository/sdk-tools-linux-3859397.zip
mkdir $ANDROID_HOME
unzip -qq /tmp/android-sdk.zip -d $ANDROID_HOME
echo y | $ANDROID_HOME/tools/bin/sdkmanager --update > /dev/null
echo y | $ANDROID_HOME/tools/bin/sdkmanager "ndk-bundle" > /dev/null

# get sources, verify and unpack
outDir=$scriptdir/openssl
cd $scriptdir
mkdir openssl
mkdir build
pushd build

curl -Lo "openssl.tar.gz" "https://www.openssl.org/source/openssl-${OPENSSL_VERSION}.tar.gz"
echo "$OPENSSL_SHA256SUM openssl.tar.gz" | sha256sum --check -

tar -xf "openssl.tar.gz"
cd openssl-${OPENSSL_VERSION}
ln -s "$scriptdir/setenv-android.sh"

# setup and build
export ANDROID_SDK_ROOT=$ANDROID_HOME
export ANDROID_NDK_ROOT=$ANDROID_NDK
if [ "$PLATFORM" == "android_armv7" ]; then
	export ARCH=arch-arm
	export EABI=arm-linux-androideabi-4.9
	EXTRA_ABI=arm-linux-androideabi
elif [ "$PLATFORM" == "android_x86" ]; then
	export ARCH=arch-x86
	export EABI=x86-4.9
	EXTRA_ABI=i686-linux-android
else
	exit 1
fi

source setenv-android.sh $ABI gnu-shared
./config shared no-ssl2 no-ssl3 --openssldir=$outDir --prefix=$outDir
sed -i "64a\CFLAG += -I$ANDROID_NDK/sysroot/usr/include/$EXTRA_ABI/ -I$ANDROID_NDK/sysroot/usr/include/ -Wno-attributes" Makefile
make CALC_VERSIONS="SHLIB_COMPAT=; SHLIB_SOVER=" build_libs > /dev/null
echo +++after make+++
make install
echo +++after instal+++

popd

find $outDir
