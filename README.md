# esp-quick-toolchain - Build ESP8266 toolchain for multiple architectures

Allows building Win32, Win64, OSX, Linux x86_64, ARM64 (aarch64) ESP8266
toolchains in a Docker containter.

## Work In Progesss

Builds work for GCC 4.9, not tested for others,

No actual testing of the built chain done yet/

## Building only native mode binaries

If you're only compiling natively, you can just clone this repo and run
````
host={linux|win64|win32|osx|arm64}  gcc={4.8|4.9|5.2|7.2}./build build
````

Note that to build a non-linux toolchain, you first need to build a linux chain in the directory.  This is because the cross compiler requires a local host executable gcc for the target architecture to build properly.

## Building full suite architectures

To build all architectures use the commands
````
git clone https://github.com/earlephilhower/esp-quick-toolchain
cd esp-quick-toolchain
docker run --user $(id -u):$(id -g) --rm -v $(pwd):/workdir earlephilhower/gcc-cross bash /workdir/buildall.sh {4.8|4.9|5.2|7.2}
````

## Status

* Tested in esp8266/arduino only
* Working with linux only
* g++7.2 requires lots of change in esp8266/arduino core
* g++5.2 compiles and run little sketches, iram overflow with bigger sketches
* g++4.8/4.9 not built yet, worth a try for exceptions handling

## Instructions

* Clone this repository somewhere into the es8266/arduino repository
* edit `./build` to select gcc version
* run `./build build`
* once finished, run `./arduino-install install`
* uninstall with `./arduino-install uninstall`

