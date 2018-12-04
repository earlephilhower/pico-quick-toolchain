#/bin/bash

gcc=${1:-4.8}
rel=${rel:-2.5.0}
subrel=${subrel:-2}

echo Multiarch build for: ${gcc} ${rel}-${subrel}

cd /workdir

./build distclean
for host in linux win64 win32 osx arm64 rpi; do
	gcc=${gcc} host=${host} rel=${rel} subrel=${subrel} ./build build
	./build clean
done
