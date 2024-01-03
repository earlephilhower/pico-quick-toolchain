# pico-quick-toolchain - Build Raspberry Pi Pico toolchain for multiple architectures

Allows building Win32, Win64, OSX, Linux x86_64, ARM64 (aarch64) and Raspberry Pi for Raspberry Pi Pico toolchains in a Docker container.

## Work In Progesss

Builds work for GCC 9.3, 10.x, and 12.x.  Others not fully tested but were building last time they were tried.

## Downloading GCC/etc. sources

Run
````
make download
````
to clone the GCC and libs needed to the repo/ directory.  This takes a while, so be patient, but it only is done once (and allows us to switch between GCC versions without redownloading anything in the future).

## Building only native mode binaries

If you're only compiling natively, you can just clone this repo and run
````
make GCC={9.3|10.2|10.3|12.1|12.3} REL=x.x.x SUBREL=x -jx  # I like -j32 on a 16-core server, adjust according to your CPU power
````

Note that to build a non-linux toolchain, you first need to build a linux chain in the directory.  This is because the cross compiler requires a local host executable gcc for the target architecture to build properly.

## Building full suite architectures

To build all architectures use the commands
````
git clone https://github.com/earlephilhower/pico-quick-toolchain
cd pico-quick-toolchain
docker run --user $(id -u):$(id -g) --rm -v $(pwd):/workdir earlephilhower/gcc-cross-v10 bash -c "cd /workdir; make -j32 GCC={9.3|10.1|10.2|10.3|12.1} REL=2.5.0 SUBREL=3 all"
````

To make a draft release of the binaries:
````
make GCC={9.3|10.2|10.3|12.1|12.3} REL=2.5.0 SUBREL=3 upload
````

You then promote the draft to a pre-release so it becomes visible and can then make a PR against the Arduino core to merge it.

Then to install the libraries and headers into the Arduino core (not including the toolchain exes) just
````
make GCC={9.3|10.2|10.3|12.1|12.3} REL=2.5.0 SUBREL=3 install  (INSTALLBRANCH=xxx may be added to apply against a predefined branch other than master)
<in Arduino dir>
git commit -a
````
