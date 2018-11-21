#/bin/bash

cd /workdir

./build build linux

./build clean
./build build win64

./build clean
./build build win32

./build clean
./build build osx

./build clean
./build build arm64

./build clean

