#!/bin/bash
set -e

OPENSSL_VERSION="$1"
ANDROID_TARGET_ARCH="$2"

scriptdir="$(dirname "$(readlink -f "$0")")"

# get sources
curl -Lo "openssl.tar.gz" "https://www.openssl.org/source/openssl-${OPENSSL_VERSION}.tar.gz"
tar -xf "openssl.tar.gz"
pushd openssl-${OPENSSL_VERSION}
ln -s "$scriptdir/setenv-android.sh"
mkdir install

# setup and build
if [ "$ANDROID_TARGET_ARCH" == "armeabi-v7a" ]; then
	export ARCH=arch-arm
	export EABI=arm-linux-androideabi-4.9
	EXTRA_ABI=arm-linux-androideabi
elif [ "$ANDROID_TARGET_ARCH" == "x86" ]; then
	export ARCH=arch-x86
	export EABI=x86-4.9
	EXTRA_ABI=i686-linux-android
else
	exit 1
fi

source setenv-android.sh $ABI gnu-shared
./config shared no-ssl2 no-ssl3 "--openssldir=$PWD/install" "--prefix=$PWD/install"
sed -i "64a\CFLAG += -I$ANDROID_NDK/sysroot/usr/include/$EXTRA_ABI/ -I$ANDROID_NDK/sysroot/usr/include/ -Wno-attributes" Makefile
make CALC_VERSIONS="SHLIB_COMPAT=; SHLIB_SOVER=" build_libs
