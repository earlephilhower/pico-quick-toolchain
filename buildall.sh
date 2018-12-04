#/bin/bash

gcc=${1:-4.8}
echo Multiarch build for: $gcc

cd /workdir

for host in linux win64 win32 osx arm64 rpi; do
	./build clean
	gcc=$gcc host=$host ./build build
done
