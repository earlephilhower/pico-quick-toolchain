
WIP - Script for building a recent toolchain for esp8266 (g++-7.2) - WIP
------------------------------------------------------------------------

* Tested in esp8266/arduino only
* Working with linux only

Instructions
------------

* Clone this repository somewhere into the es8266/arduino repository
* run `./build build`
* once finished, run `./arduino-install install`
* uninstall with `./arduino-install uninstall`

```
$ xtensa-lx106-elf/bin/xtensa-lx106-elf-g++ -v
Using built-in specs.
COLLECT_GCC=./xtensa-lx106-elf/bin/xtensa-lx106-elf-g++
COLLECT_LTO_WRAPPER=[...]xtensa-lx106-elf/bin/../libexec/gcc/xtensa-lx106-elf/7.2.0/lto-wrapper
Target: xtensa-lx106-elf
Configured with: ../../dl/gcc-xtensa/configure --prefix=[...]xtensa-lx106-elf --target=xtensa-lx106-elf --disable-shared --with-newlib --enable-threads=no --disable-__cxa_atexit --enable-target-optspace --disable-libgomp --disable-libmudflap --disable-nls --disable-multilib --enable-languages=c,c++ --disable-bootstrap --enable-lto --disable-libstdcxx-verbose --with-endian=little
Thread model: single
gcc version 7.2.0 (GCC) 
```
