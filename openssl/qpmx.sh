#!/bin/bash
set -e

OPENSSL_VERSION="$1"
ANDROID_TARGET_ARCH="$2"
TOOLCHAIN_VERSION=4.9
HOST_ARCH=linux-x86_64

scriptdir="$(dirname "$(readlink -f "$0")")"

# get sources
curl -Lo "openssl.tar.gz" "https://www.openssl.org/source/openssl-${OPENSSL_VERSION}.tar.gz"
tar -xf "openssl.tar.gz"
pushd openssl-${OPENSSL_VERSION}

case "$ANDROID_TARGET_ARCH" in
	arm64-v8a)
		API_VERSION=21
		ARCH_ID=android-arm64
		TOOLCHAIN=aarch64-linux-android-$TOOLCHAIN_VERSION
		;;
	armeabi-v7a)
		API_VERSION=16
		ARCH_ID=android-arm
		TOOLCHAIN=arm-linux-android-$TOOLCHAIN_VERSION
		;;
	x86)
		API_VERSION=16
		ARCH_ID=android-x86
		TOOLCHAIN=x86-$TOOLCHAIN_VERSION
		;;
	*)
		echo "Unsupported ANDROID_TARGET_ARCH: $ANDROID_TARGET_ARCH"
		exit 1
		;;
esac

export ANDROID_NDK=$ANDROID_NDK_ROOT
export PATH=$ANDROID_NDK/toolchains/llvm/prebuilt/$HOST_ARCH/bin/:$ANDROID_NDK/toolchains/$TOOLCHAIN/prebuilt/$HOST_ARCH/bin:$PATH
./Configure $ARCH_ID shared no-ssl3 -D__ANDROID_API__=$API_VERSION
make depend
exec make SHLIB_VERSION_NUMBER= SHLIB_EXT=.so build_libs
