
WIP - Script for building a recent toolchain for esp8266 (g++-7.2) - WIP
------------------------------------------------------------------------
or an older one with nice features - refs:
* https://github.com/esp8266/Arduino/issues/1351#issuecomment-392838263
* https://github.com/esp8266/Arduino/pull/4694
* https://github.com/esp8266/Arduino/pull/4687
* https://github.com/esp8266/Arduino/issues/4520)

Status
------

* Tested in esp8266/arduino only
* Working with linux only
* g++7.2 requires lots of change in esp8266/arduino core
* g++5.2 compiles and run little sketches, iram overflow with bigger sketches
* g++4.8/4.9 not built yet, worth a try for exceptions handling

Instructions
------------

* Clone this repository somewhere into the es8266/arduino repository
* edit `./build` to select gcc version
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
