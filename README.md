# esp-quick-toolchain - Build ESP8266 toolchain for multiple architectures

Allows building Win32, Win64, OSX, Linux x86_64, ARM64 (aarch64) and Raspberry
Pi ESP8266 toolchains in a Docker container.

## Work In Progesss

Builds work for GCC 4.8, others not fully tested but were building last time they were tested

## Building only native mode binaries

If you're only compiling natively, you can just clone this repo and run
````
host={linux|win64|win32|osx|arm64|rpi} gcc={4.8|4.9|5.2|7.2} ./build build
````

Note that to build a non-linux toolchain, you first need to build a linux chain in the directory.  This is because the cross compiler requires a local host executable gcc for the target architecture to build properly.

## Building full suite architectures

To build all architectures use the commands
````
git clone https://github.com/earlephilhower/esp-quick-toolchain
cd esp-quick-toolchain
docker run --user $(id -u):$(id -g) --rm -v $(pwd):/workdir earlephilhower/gcc-cross bash -c "cd /workdir; make -j32 GCC={4.8|4.9|5.2|7.2} REL=2.5.0 SUBREL=3 all"
````

To make a draft release of the binaries:
````
make GCC={4.8|4.9|5.2|7.2} REL=2.5.0 SUBREL=3 upload
````

Then to install the libraries and headers into the Arduino core (not including the toolchain exes) just
````
make GCC={4.8|4.9|5.2|7.2} REL=2.5.0 SUBREL=3 install  (INSTALLBRANCH=xxx may be added to apply against a predefined branch otehr than master)
<in Arduino dir>
git commit -a
````
