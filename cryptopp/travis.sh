#!/bin/bash
set -e

export XZ_OPT=-9
export CRYPTOPP_NAME=CRYPTOPP_${CRYPTOPP_VERSION}

if [[ "$TRAVIS_OS_NAME" == "osx" ]]; then
	scriptdir=$(dirname $(greadlink -f $0))
else
	scriptdir=$(dirname $(readlink -f $0))
fi

if [[ "$PLATFORM" == "linux" ]]; then
	docker run --rm --name docker-build -e XZ_OPT -e CRYPTOPP_VERSION -e CRYPTOPP_NAME -e CRYPTOPP_SHA512SUM -v "$scriptdir:/root/project" ubuntu:latest bash /root/project/linux.sh
fi

if [[ "$PLATFORM" == "android_armv7" ]]; then
	docker run --rm --name docker-build -e XZ_OPT -e CRYPTOPP_VERSION -e CRYPTOPP_NAME -e CRYPTOPP_SHA512SUM -v "$scriptdir:/root/project" ubuntu:latest bash /root/project/android.sh armv7a
fi

if [[ "$PLATFORM" == "android_x86" ]]; then
	docker run --rm --name docker-build -e XZ_OPT -e CRYPTOPP_VERSION -e CRYPTOPP_NAME -e CRYPTOPP_SHA512SUM -v "$scriptdir:/root/project" ubuntu:latest bash /root/project/android.sh x86
fi

if [[ "$PLATFORM" == "macos" ]]; then
	$scriptdir/macos.sh
fi

if [[ "$PLATFORM" == "ios" ]]; then
	$scriptdir/ios.sh
fi

# pack up for deployment
cd $scriptdir
tar cJf cryptopp_${CRYPTOPP_VERSION}_${PLATFORM}.tar.xz cryptopp
