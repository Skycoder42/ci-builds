#!/bin/bash
set -e

export XZ_OPT=-9
export CRYPTOPP_VERSION=5_6_5
export CRYPTOPP_NAME=CRYPTOPP_${CRYPTOPP_VERSION}
export CRYPTOPP_SHA512SUM=82e9a51080ace2734bfe4ba932c31e6a963cb20b570f0fea2fbe9ceccb887c8afecb36cde91c46ac6fea1357fdff6320ab2535b3f0aa48424acdd2cd9dd2e880

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

if [[ "$PLATFORM" == "clang_64" ]]; then
	$scriptdir/macos.sh
fi

if [[ "$PLATFORM" == "ios" ]]; then
	$scriptdir/ios.sh
fi

# pack up for deployment
cd $scriptdir
tar cJf cryptopp_${CRYPTOPP_VERSION}_${PLATFORM}.tar.xz cryptopp
