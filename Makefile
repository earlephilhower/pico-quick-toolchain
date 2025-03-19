
ifneq ($(V),1)
.SILENT:
endif

# General rule is that CAPITAL variables are constants and can be used
# via $(VARNAME), while lowercase variables are dynamic and need to be
# used via $(call varname,$@) (note no space between comma and $@)

REL     := $(if $(REL),$(REL),1.0.0)
ARDUINO := $(if $(ARDUINO),$(ARDUINO),$(shell pwd)/arduino)
GCC     := $(if $(GCC),$(GCC),12.4)

# General constants
PWD      := $(shell pwd)
REPODIR  := $(PWD)/repo
PATCHDIR := $(PWD)/patches
STAMP    := $(shell date +%y%m%d)
ifneq ($(RISCV), 1)
ARCH     := arm-none-eabi
CPPLIBPATH := thumb
else
ARCH     := riscv32-unknown-elf
CPPLIBPATH := rv32imac/ilp32
endif

# For uploading, the GH user and PAT
GHUSER := $(if $(GHUSER),$(GHUSER),$(shell cat .ghuser))
GHTOKEN := $(if $(GHTOKEN),$(GHTOKEN),$(shell cat .ghtoken))
ifeq ($(GHUSER),)
    $(error Need to specify GH username on the command line "GHUSER=xxxx" or in .ghuser)
else ifeq ($(GHTOKEN),)
    $(error Need to specify GH PAT on the command line "GHTOKEN=xxxx" or in .ghtoken)
endif
PLATFORMIO := ~/.platformio/penv/bin/platformio

NEWLIB_DIR    := newlib
NEWLIB_REPO   := git://sourceware.org/git/newlib-cygwin.git
NEWLIB_BRANCH := newlib-4.3.0

# Depending on the GCC version get proper branch and support libs
GNUHTTP := https://gcc.gnu.org/pub/gcc/infrastructure
ifeq ($(GCC), 6.3)
    ISL           := 0.16.1
    GCC_BRANCH    := releases/gcc-6.3.0
    GCC_PKGREL    := 60300
    GCC_REPO      := https://gcc.gnu.org/git/gcc.git
    GCC_DIR       := gcc-gnu
    BINUTILS_BRANCH := binutils-2_32
    BINUTILS_REPO := https://sourceware.org/git/binutils-gdb.git
    BINUTILS_DIR  := binutils-gdb-gnu
    NEWLIB_BRANCH := newlib-2_4_0
else ifeq ($(GCC), 9.3)
    ISL           := 0.18
    GCC_BRANCH    := releases/gcc-9.3.0
    GCC_PKGREL    := 90300
    GCC_REPO      := https://gcc.gnu.org/git/gcc.git
    GCC_DIR       := gcc-gnu
    BINUTILS_BRANCH := binutils-2_32
    BINUTILS_REPO := https://sourceware.org/git/binutils-gdb.git
    BINUTILS_DIR  := binutils-gdb-gnu
else ifeq ($(GCC), 10.2)
    ISL           := 0.18
    GCC_BRANCH    := releases/gcc-10.2.0
    GCC_PKGREL    := 100200
    GCC_REPO      := https://gcc.gnu.org/git/gcc.git
    GCC_DIR       := gcc-gnu
    BINUTILS_BRANCH := binutils-2_32
    BINUTILS_REPO := https://sourceware.org/git/binutils-gdb.git
    BINUTILS_DIR  := binutils-gdb-gnu
else ifeq ($(GCC), 10.3)
    ISL           := 0.18
    GCC_BRANCH    := releases/gcc-10.3.0
    GCC_PKGREL    := 100300
    GCC_REPO      := https://gcc.gnu.org/git/gcc.git
    GCC_DIR       := gcc-gnu
    BINUTILS_BRANCH := binutils-2_32
    BINUTILS_REPO := https://sourceware.org/git/binutils-gdb.git
    BINUTILS_DIR  := binutils-gdb-gnu
else ifeq ($(GCC), 10.4)
    ISL           := 0.18
    GCC_BRANCH    := releases/gcc-10.4.0
    GCC_PKGREL    := 100400
    GCC_REPO      := https://gcc.gnu.org/git/gcc.git
    GCC_DIR       := gcc-gnu
    BINUTILS_BRANCH := binutils-2_36
    BINUTILS_REPO := https://sourceware.org/git/binutils-gdb.git
    BINUTILS_DIR  := binutils-gdb-gnu
else ifeq ($(GCC), 10.5)
    ISL           := 0.18
    GCC_BRANCH    := releases/gcc-10.5.0
    GCC_PKGREL    := 100400
    GCC_REPO      := https://gcc.gnu.org/git/gcc.git
    GCC_DIR       := gcc-gnu
    BINUTILS_BRANCH := binutils-2_36
    BINUTILS_REPO := https://sourceware.org/git/binutils-gdb.git
    BINUTILS_DIR  := binutils-gdb-gnu
else ifeq ($(GCC), 12.1)
    ISL           := 0.18
    GCC_BRANCH    := releases/gcc-12.1.0
    GCC_PKGREL    := 120100
    GCC_REPO      := https://gcc.gnu.org/git/gcc.git
    GCC_DIR       := gcc-gnu
    BINUTILS_BRANCH := binutils-2_32
    BINUTILS_REPO := https://sourceware.org/git/binutils-gdb.git
    BINUTILS_DIR  := binutils-gdb-gnu
else ifeq ($(GCC), 12.2)
    ISL           := 0.18
    GCC_BRANCH    := releases/gcc-12.2.0
    GCC_PKGREL    := 120200
    GCC_REPO      := https://gcc.gnu.org/git/gcc.git
    GCC_DIR       := gcc-gnu
    BINUTILS_BRANCH := binutils-2_38
    BINUTILS_REPO := https://sourceware.org/git/binutils-gdb.git
    BINUTILS_DIR  := binutils-gdb-gnu
else ifeq ($(GCC), 12.3)
    ISL           := 0.18
    GCC_BRANCH    := releases/gcc-12.3.0
    GCC_PKGREL    := 120300
    GCC_REPO      := https://gcc.gnu.org/git/gcc.git
    GCC_DIR       := gcc-gnu
    BINUTILS_BRANCH := gdb-13.2-release #binutils-2_38
    BINUTILS_REPO := https://sourceware.org/git/binutils-gdb.git
    BINUTILS_DIR  := binutils-gdb-gnu
else ifeq ($(GCC), 12.4)
    ISL           := 0.18
    GCC_BRANCH    := releases/gcc-12.4.0
    GCC_PKGREL    := 120400
    GCC_REPO      := https://gcc.gnu.org/git/gcc.git
    GCC_DIR       := gcc-gnu
    BINUTILS_BRANCH := gdb-13.2-release #binutils-2_38
    BINUTILS_DIR  := binutils-gdb-gnu
    BINUTILS_REPO := https://sourceware.org/git/binutils-gdb.git
else ifeq ($(GCC), 13.2)
    ISL           := 0.18
    GCC_BRANCH    := releases/gcc-13.2.0
    GCC_PKGREL    := 130200
    GCC_REPO      := https://gcc.gnu.org/git/gcc.git
    GCC_DIR       := gcc-gnu
    BINUTILS_BRANCH := gdb-13.2-release #binutils-2_41
    BINUTILS_REPO := https://sourceware.org/git/binutils-gdb.git
    BINUTILS_DIR  := binutils-gdb-gnu
else ifeq ($(GCC), 14.2)
    ISL           := 0.18
    GCC_BRANCH    := releases/gcc-14.2.0
    GCC_PKGREL    := 140200
    GCC_REPO      := https://gcc.gnu.org/git/gcc.git
    GCC_DIR       := gcc-gnu
    BINUTILS_BRANCH := binutils-2_43_1
    BINUTILS_REPO := https://sourceware.org/git/binutils-gdb.git
    BINUTILS_DIR  := binutils-gdb-gnu
else
    $(error Need to specify a supported GCC version "GCC={9.3, 10.2, 10.3, 12.1}")
endif

# Define the build and output naming, don't use directly (see below)
LINUX_HOST   := x86_64-linux-gnu
LINUX_AHOST  := x86_64-pc-linux-gnu
LINUX_EXT    := .x86_64
LINUX_EXE    := 
LINUX_MKTGT  := linux
LINUX_BFLGS  := LDFLAGS=-static
LINUX_TARCMD := tar
LINUX_TAROPT := zcf
LINUX_TAREXT := tar.gz
LINUX_ASYS   := linux_x86_64
LINUX_DEB    := amd64
LINUX_STATIC := -static-libgcc -static-libstdc++

LINUX32_HOST   := i686-linux-gnu
LINUX32_AHOST  := i686-pc-linux-gnu
LINUX32_EXT    := .i686
LINUX32_EXE    := 
LINUX32_MKTGT  := linux
LINUX32_BFLGS  := LDFLAGS=-static
LINUX32_TARCMD := tar
LINUX32_TAROPT := zcf
LINUX32_TAREXT := tar.gz
LINUX32_ASYS   := linux_i686
LINUX32_DEB    := i386
LINUX32_STATIC := -static-libgcc -static-libstdc++

WIN32_HOST   := i686-w64-mingw32
WIN32_AHOST  := i686-mingw32
WIN32_EXT    := .win32
WIN32_EXE    := .exe
WIN32_MKTGT  := windows
WIN32_BFLGS  := LDFLAGS=-static
WIN32_TARCMD := zip
WIN32_TAROPT := -rq
WIN32_TAREXT := zip
WIN32_ASYS   := windows_x86
WIN32_LSSP   := -lssp
WIN32_STATIC := -static-libgcc -static-libstdc++

WIN64_HOST   := x86_64-w64-mingw32
WIN64_AHOST  := x86_64-mingw32
WIN64_EXT    := .win64
WIN64_EXE    := .exe
WIN64_MKTGT  := windows
WIN64_BFLGS  := LDFLAGS=-static
WIN64_TARCMD := zip
WIN64_TAROPT := -rq
WIN64_TAREXT := zip
WIN64_ASYS   := windows_amd64
WIN64_LSSP   := -lssp
WIN64_STATIC := -static-libgcc -static-libstdc++

MACOSX86_HOST   := x86_64-apple-darwin20.4
MACOSX86_AHOST  := x86_64-apple-darwin
MACOSX86_EXT    := .macosx86
MACOSX86_EXE    :=
MACOSX86_MKTGT  := macosx86
MACOSX86_BFLGS  :=
MACOSX86_TARCMD := tar
MACOSX86_TAROPT := zcf
MACOSX86_TAREXT := tar.gz
MACOSX86_ASYS   := darwin_x86_64
MACOSX86_STATIC := -static-libgcc -static-libstdc++

MACOSARM_HOST   := aarch64-apple-darwin20.4
MACOSARM_AHOST  := arm64-apple-darwin
MACOSARM_EXT    := .macosarm
MACOSARM_EXE    :=
MACOSARM_MKTGT  := macosarm
MACOSARM_BFLGS  :=
MACOSARM_TARCMD := tar
MACOSARM_TAROPT := zcf
MACOSARM_TAREXT := tar.gz
MACOSARM_ASYS   := darwin_arm64
MACOSARM_OVER   := CC=$(MACOSARM_HOST)-cc CXX=$(MACOSARM_HOST)-c++ STRIP=touch
MACOSARM_STATIC := -lc -lc++

ARM64_HOST   := aarch64-linux-gnu
ARM64_AHOST  := aarch64-linux-gnu
ARM64_EXT    := .arm64
ARM64_EXE    := 
ARM64_MKTGT  := linux
ARM64_BFLGS  := LDFLAGS=-static
ARM64_TARCMD := tar
ARM64_TAROPT := zcf
ARM64_TAREXT := tar.gz
ARM64_ASYS   := linux_aarch64
ARM64_DEB    := arm64
ARM64_STATIC := -static-libgcc -static-libstdc++

RPI_HOST   := arm-linux-gnueabihf
RPI_AHOST  := arm-linux-gnueabihf
RPI_EXT    := .rpi
RPI_EXE    := 
RPI_MKTGT  := linux
RPI_BFLGS  := LDFLAGS=-static
RPI_TARCMD := tar
RPI_TAROPT := zcf
RPI_TAREXT := tar.gz
RPI_ASYS   := linux_armv6l\",\ \"linux_armv7l
RPI_DEB    := armhf
RPI_STATIC := -static-libgcc -static-libstdc++

# Call with $@ to get the appropriate variable for this architecture
host   = $($(call arch,$(1))_HOST)
ahost  = $($(call arch,$(1))_AHOST)
ext    = $($(call arch,$(1))_EXT)
exe    = $($(call arch,$(1))_EXE)
mktgt  = $($(call arch,$(1))_MKTGT)
bflgs  = $($(call arch,$(1))_BFLGS)
tarcmd = $($(call arch,$(1))_TARCMD)
taropt = $($(call arch,$(1))_TAROPT)
tarext = $($(call arch,$(1))_TAREXT)
deb    = $($(call arch,$(1))_DEB)
lssp   = $($(call arch,$(1))_LSSP)
over   = $($(call arch,$(1))_OVER)
static = $($(call arch,$(1))_STATIC)
log    = log$(1)

# For package.json
asys   = $($(call arch,$(1))_ASYS)

# The build directory per architecture
arena = $(PWD)/arena$(call ext,$(1))
# The architecture for this recipe
arch = $(subst .,,$(suffix $(basename $(1))))
# This installation directory for this architecture
install = $(call arena,$(1))/$(ARCH)

# Binary stuff we need to access
BLOBS = $(PWD)/blobs

# GNU infra
GMP_VER := 6.2.1

# RPI stuff
PICOSDK_BRANCH  := develop
OPENOCD_BRANCH  := sdk-2.0.0
PICOTOOL_BRANCH := 2.1.1

# GCC et. al configure options
#configure  = --prefix=$(call install,$(1))
configure  =
configure += --build=$(shell gcc -dumpmachine)
configure += --host=$(call host,$(1))
#configure += --target=$(ARCH)
configure += --disable-shared
configure += --with-newlib
configure += --enable-threads=no
configure += --disable-__cxa_atexit
configure += --disable-libgomp
configure += --disable-libmudflap
configure += --disable-nls
configure += --without-python
configure += --disable-bootstrap
configure += --enable-languages=c,c++
configure += --disable-lto
configure += --enable-static=yes
configure += --disable-libstdcxx-verbose
configure += --disable-decimal-float
#configure += --with-cpu=cortex-m0plus
#configure += --with-no-thumb-interwork
configure += --disable-tui
configure += --disable-pie-tools
configure += --disable-libquadmath
configure += $(call over,$(1))


# Newlib configuration common
CONFIGURENEWLIBCOM  = --with-newlib
CONFIGURENEWLIBCOM += --disable-newlib-io-c99-formats
CONFIGURENEWLIBCOM += --disable-newlib-supplied-syscalls
CONFIGURENEWLIBCOM += --enable-newlib-nano-formatted-io
CONFIGURENEWLIBCOM += --enable-newlib-reent-small
CONFIGURENEWLIBCOM += --disable-target-optspace
CONFIGURENEWLIBCOM += --disable-option-checking
#CONFIGURENEWLIBCOM += --target=$(ARCH)
CONFIGURENEWLIBCOM += --disable-shared
#CONFIGURENEWLIBCOM += --with-cpu=cortex-m0plus
#CONFIGURENEWLIBCOM += --with-no-thumb-interwork
CONFIGURENEWLIBCOM += --enable-newlib-retargetable-locking

# OpenOCD configuration
CONFIGOPENOCD  = --enable-picoprobe
CONFIGOPENOCD += --enable-cmsis-dap
CONFIGOPENOCD += --enable-sysfsgpio
CONFIGOPENOCD += --enable-bcm2835gpio
CONFIGOPENOCD += --enable-cmsis-dap-v2
CONFIGOPENOCD += --disable-werror
CONFIGOPENOCD += --disable-dummy
CONFIGOPENOCD += --disable-rshim
CONFIGOPENOCD += --disable-ftdi
CONFIGOPENOCD += --disable-stlink
CONFIGOPENOCD += --disable-ti-icdi
CONFIGOPENOCD += --disable-ulink
CONFIGOPENOCD += --disable-usb-blaster-2
CONFIGOPENOCD += --disable-ft232r
CONFIGOPENOCD += --disable-vsllink
CONFIGOPENOCD += --disable-xds110
CONFIGOPENOCD += --disable-osbdm
CONFIGOPENOCD += --disable-opendous
CONFIGOPENOCD += --disable-aice
CONFIGOPENOCD += --disable-usbprog
CONFIGOPENOCD += --disable-rlink
CONFIGOPENOCD += --disable-armjtagew
CONFIGOPENOCD += --disable-nulink
CONFIGOPENOCD += --disable-kitprog
CONFIGOPENOCD += --disable-usb-blaster
CONFIGOPENOCD += --disable-presto
CONFIGOPENOCD += --disable-openjtag
CONFIGOPENOCD += --disable-jlink
CONFIGOPENOCD += --disable-parport
CONFIGOPENOCD += --disable-parport-ppdev
CONFIGOPENOCD += --disable-parport-giveio
CONFIGOPENOCD += --disable-jtag_vpi
CONFIGOPENOCD += --disable-jtag_dpi
CONFIGOPENOCD += --disable-amtjtagaccel
CONFIGOPENOCD += --disable-zy1000-master
CONFIGOPENOCD += --disable-zy1000
CONFIGOPENOCD += --disable-ioutil
CONFIGOPENOCD += --disable-imx_gpio
CONFIGOPENOCD += --disable-ep93xx
CONFIGOPENOCD += --disable-at91rm9200
CONFIGOPENOCD += --disable-gw16012
CONFIGOPENOCD += --disable-oocd_trace
CONFIGOPENOCD += --disable-buspirate
CONFIGOPENOCD += --disable-xlnx-pcie-xvc
CONFIGOPENOCD += --disable-minidriver-dummy
CONFIGOPENOCD += --disable-remote-bitbang

# The branch in which to store the new toolchain
INSTALLBRANCH ?= master

# Environment variables for configure and building targets.  Only use $(call setenv,$@)
CFFT := "-O2 -g -free -fipa-pta -Wno-implicit-function-declaration"

# Sets the environment variables for a subshell while building
setenvtgtcross = export CFLAGS_FOR_TARGET=$(CFFT); \
         export CXXFLAGS_FOR_TARGET=$(CFFT); \
         export CFLAGS="-I$(call arena,$(1))/$$TGT/include -I$(call arena,$(1))/cross/include -pipe -g -O2"; \
         export CXXFLAGS="-pipe -g -O2"; \
         export LDFLAGS="-L$(call arena,$(1))/$$TGT/lib -L$(call arena,$(1))/cross/lib"; \
         export PATH="$(call arena,.stage.LINUX.stage)/$$TGT/bin:$${PATH}"; \
         export LD_LIBRARY_PATH="$(call arena,.stage.LINUX.stage)/$$TGT/lib:$${LD_LIBRARY_PATH}"

setenvtgt = export CFLAGS_FOR_TARGET=$(CFFT); \
            export CXXFLAGS_FOR_TARGET=$(CFFT); \
            export CFLAGS="-I$(call arena,$(1))/$$TGT/include -I$(call arena,$(1))/cross/include -pipe -g -O2"; \
            export CXXFLAGS="-pipe -g -O2"; \
            export LDFLAGS="-L$(call arena,$(1))/$$TGT/lib -L$(call arena,$(1))/cross/lib"; \
            export PATH="$(call arena,$(1))/$$TGT/bin:$${PATH}"; \
            export LD_LIBRARY_PATH="$(call arena,$(1))/$$TGT/lib:$${LD_LIBRARY_PATH}"

# Creates a package.json file for PlatformIO
# Package version **must** conform with Semantic Versioning specicfication:
# - https://github.com/platformio/platformio-core/issues/3612
# - https://semver.org/
makepackagejson = ( echo '{' && \
                    echo '   "description": "'$${pkgdesc}'",' && \
                    echo '   "name": "'$${pkgname}'",' && \
                    echo '   "system": [ "'$(call asys,$(1))'" ],' && \
                    echo '   "url": "https://github.com/'$(GHUSER)'/pico-quick-toolchain",' && \
                    echo '   "version": "5.'$(GCC_PKGREL)'.'$(STAMP)'"' && \
                    echo '}' ) > package.json

# Generates a JSON fragment for an uploaded release artifact
makejson = tarballsize=$$(stat -c%s $${tarball}); \
	   tarballsha256=$$(sha256sum $${tarball} | cut -f1 -d" "); \
	   ( echo '{' && \
	     echo ' "host": "'$(call ahost,$(1))'",' && \
	     echo ' "url": "https://github.com/$(GHUSER)/pico-quick-toolchain/releases/download/'$(REL)'/'$${tarball}'",' && \
	     echo ' "archiveFileName": "'$${tarball}'",' && \
	     echo ' "checksum": "SHA-256:'$${tarballsha256}'",' && \
	     echo ' "size": "'$${tarballsize}'"' && \
	     echo '}') > $${tarball}.json

# Dummp all the git hashed/tags being built
makegitlog = for i in binutils-gdb-gnu gcc-gnu mklittlefs newlib openocd pico-sdk picotool; do (cd $(REPODIR)/$$i && echo -n $$i: && git describe --tags --always); done

# The recpies begin here.

linux default: .stage.LINUX.done

.PRECIOUS: .stage.% .stage.%.%

.PHONY: .stage.download

# Build all toolchain versions
all: .stage.LINUX.done .stage.LINUX32.done .stage.WIN32.done .stage.WIN64.done .stage.MACOSX86.done .stage.MACOSARM.done .stage.ARM64.done .stage.RPI.done
	echo STAGE: $@
	echo All complete

download: .stage.download

pioasm: .stage.LINUX32.pioasm .stage.WIN32.pioasm .stage.WIN64.pioasm .stage.MACOSX86.pioasm .stage.MACOSARM.pioasm .stage.ARM64.pioasm .stage.RPI.pioasm .stage.LINUX.pioasm

mklittlefs: .stage.LINUX32.mklittlefs .stage.WIN32.mklittlefs .stage.WIN64.mklittlefs .stage.MACOSX86.mklittlefs .stage.MACOSARM.mklittlefs .stage.ARM64.mklittlefs .stage.RPI.mklittlefs .stage.LINUX.mklittlefs

openocd: .stage.LINUX32.openocd .stage.WIN32.openocd .stage.WIN64.openocd .stage.MACOSX86.openoce .stage.MACOSARM.openocd .stage.ARM64.openocd .stage.RPI.openocd .stage.LINUX.openocd

picotool: .stage.LINUX32.picotool .stage.WIN32.picotool .stage.WIN64.picotool .stage.MACOSX86.picotool .stage.MACOSARM.picotool .stage.ARM64.picotool .stage.RPI.picotool .stage.LINUX.picotool

# Other cross-compile cannot start until Linux is built
.stage.LINUX32.gcc1-make                     .stage.WIN32.gcc1-make                     .stage.WIN64.gcc1-make                     .stage.MACOSX86.gcc1-make                     .stage.MACOSARM.gcc1-make                     .stage.ARM64.gcc1-make                     .stage.RPI.gcc1-make:                     .stage.LINUX.done
.stage.LINUX32.gcc1-make_arm-none-eabi       .stage.WIN32.gcc1-make_arm-none-eabi       .stage.WIN64.gcc1-make_arm-none-eabi       .stage.MACOSX86.gcc1-make_arm-none-eabi       .stage.MACOSARM.gcc1-make_arm-none-eabi       .stage.ARM64.gcc1-make_arm-none-eabi       .stage.RPI.gcc1-make_arm-none-eabi:       .stage.LINUX.done
.stage.LINUX32.gcc1-make_riscv32-unknown-elf .stage.WIN32.gcc1-make_riscv32-unknown-elf .stage.WIN64.gcc1-make_riscv32-unknown-elf .stage.MACOSX86.gcc1-make_riscv32-unknown-elf .stage.MACOSARM.gcc1-make_riscv32-unknown-elf .stage.ARM64.gcc1-make_riscv32-unknown-elf .stage.RPI.gcc1-make_riscv32-unknown-elf: .stage.LINUX.done

# Clean all temporary outputs
clean: .cleaninst.LINUX.clean .cleaninst.LINUX32.clean .cleaninst.WIN32.clean .cleaninst.WIN64.clean .cleaninst.MACOSX86.clean .cleaninst.MACOSARM.clean .cleaninst.ARM64.clean .cleaninst.RPI.clean
	echo STAGE: $@
	rm -rf .stage* *.json *.tar.gz *.zip venv $(ARDUINO) pkg.* log.* > /dev/null 2>&1

# Clean an individual architecture and arena dir
.cleaninst.%.clean:
	echo STAGE: $@
	rm -rf $(call install,$@) > /dev/null 2>&1
	rm -rf $(call arena,$@) > /dev/null 2>&1

# Download the needed GIT and tarballs
.stage.download:
	echo STAGE: $@
	mkdir -p $(REPODIR) > $(call log,$@) 2>&1
	(test -d $(REPODIR)/$(BINUTILS_DIR) || git clone $(BINUTILS_REPO)                               $(REPODIR)/$(BINUTILS_DIR) ) >> $(call log,$@) 2>&1
	(test -d $(REPODIR)/$(GCC_DIR)      || git clone $(GCC_REPO)                                    $(REPODIR)/$(GCC_DIR)  ) >> $(call log,$@) 2>&1
	(test -d $(REPODIR)/newlib          || git clone $(NEWLIB_REPO)                                 $(REPODIR)/newlib      ) >> $(call log,$@) 2>&1
	(test -d $(REPODIR)/mklittlefs      || git clone https://github.com/$(GHUSER)/mklittlefs.git    $(REPODIR)/mklittlefs  ) >> $(call log,$@) 2>&1
	(test -d $(REPODIR)/pico-sdk        || git clone https://github.com/raspberrypi/pico-sdk.git    $(REPODIR)/pico-sdk    ) >> $(call log,$@) 2>&1
	(test -d $(REPODIR)/openocd         || git clone https://github.com/raspberrypi/openocd.git     $(REPODIR)/openocd     ) >> $(call log,$@) 2>&1
	(test -d $(REPODIR)/picotool        || git clone https://github.com/raspberrypi/picotool.git    $(REPODIR)/picotool    ) >> $(call log,$@) 2>&1
	(test -d $(REPODIR)/libexpat        || git clone https://github.com/libexpat/libexpat.git       $(REPODIR)/libexpat    ) >> $(call log,$@) 2>&1
	touch $@

# Completely clean out a git directory, removing any untracked files
.clean.%.git:
	echo STAGE: $@
	(cd $(REPODIR)/$(call arch,$@) && git reset --hard HEAD && git clean -f -d) > $(call log,$@) 2>&1

.clean.gits: .clean.$(BINUTILS_DIR).git .clean.$(GCC_DIR).git .clean.newlib.git .clean.newlib.git .clean.mklittlefs.git .clean.pico-sdk.git .clean.openocd.git .clean.picotool.git

# Prep the git repos with no patches and any required libraries for gcc
.stage.prepgit: .stage.download .clean.gits
	echo STAGE: $@
	for i in $(BINUTILS_DIR) $(GCC_DIR) newlib mklittlefs pico-sdk openocd libexpat; do \
            cd $(REPODIR)/$$i && git reset --hard HEAD && git submodule init && git submodule update && git clean -f -d; \
        done > $(call log,$@) 2>&1
	for url in $(GNUHTTP)/gmp-$(GMP_VER).tar.bz2 $(GNUHTTP)/mpfr-3.1.4.tar.bz2 $(GNUHTTP)/mpc-1.0.3.tar.gz \
	           $(GNUHTTP)/isl-$(ISL).tar.bz2 $(GNUHTTP)/cloog-0.18.1.tar.gz; do \
	    archive=$${url##*/}; name=$${archive%.t*}; base=$${name%-*}; ext=$${archive##*.} ; \
	    echo "-------- getting $${name}" ; \
	    cd $(REPODIR) && ( test -r $${archive} || wget $${url} ) ; \
	    case "$${ext}" in \
	        gz)  (cd $(REPODIR)/$(GCC_DIR); tar xfz ../$${archive});; \
	        bz2) (cd $(REPODIR)/$(GCC_DIR); tar xfj ../$${archive});; \
	    esac ; \
	    (cd $(REPODIR)/$(GCC_DIR); rm -rf $${base}; ln -s $${name} $${base}) \
	done >> $(call log,$@) 2>&1
	(cd  $(REPODIR)/openocd && ./bootstrap) >> $(call log,$@) 2>&1
	touch $@

# Checkout any required branches
.stage.checkout: .stage.prepgit
	echo STAGE: $@
	(cd $(REPODIR)/$(GCC_DIR) && git reset --hard && git checkout $(GCC_BRANCH)) > $(call log,$@) 2>&1
	(cd $(REPODIR)/$(BINUTILS_DIR) && git reset --hard && git checkout $(BINUTILS_BRANCH)) >> $(call log,$@) 2>&1
	(cd $(REPODIR)/$(NEWLIB_DIR) && git reset --hard && git checkout $(NEWLIB_BRANCH)) >> $(call log,$@) 2>&1
	(cd $(REPODIR)/openocd && git reset --hard && git checkout $(OPENOCD_BRANCH) && git submodule update --init --recursive) >> $(call log,$@) 2>&1
	(cd $(REPODIR)/picotool && git reset --hard && git checkout $(PICOTOOL_BRANCH) && git submodule update --init --recursive) >> $(call log,$@) 2>&1
	(cd $(REPODIR)/libexpat && git reset --hard && git checkout R_2_4_4 && git submodule update --init --recursive) >> $(call log,$@) 2>&1
	(cd $(REPODIR)/pico-sdk && git reset --hard && git checkout $(PICOSDK_BRANCH)) >> $(call log,$@) 2>&1
	touch $@

# Apply our patches
.stage.patch: .stage.checkout
	echo STAGE: $@
	for p in $(PATCHDIR)/gcc-*.patch $(PATCHDIR)/gcc$(GCC)/gcc-*.patch; do \
	    test -r "$$p" || continue ; \
	    (cd $(REPODIR)/$(GCC_DIR); echo "---- $$p:"; patch -s -p1 < $$p) ; \
	done > $(call log,$@) 2>&1
	for p in $(PATCHDIR)/bin-*.patch $(PATCHDIR)/binutils-$(BINUTILS_BRANCH); do \
	    test -r "$$p" || continue ; \
	    test -f "$$p" || continue ; \
	    (cd $(REPODIR)/$(BINUTILS_DIR); echo "---- $$p:"; patch -s -p1 < $$p) ; \
	done >> $(call log,$@) 2>&1
	for p in $(PATCHDIR)/lib-*.patch; do \
	    test -r "$$p" || continue ; \
	    (cd $(REPODIR)/newlib; echo "---- $$p: "; patch -s -p1 < $$p) ; \
	done >> $(call log,$@) 2>&1
	for p in $(PATCHDIR)/openocd-*.patch; do \
            test -r "$$p" || continue ; \
	    (cd $(REPODIR)/openocd; echo "---- $$p: "; patch -s -p1 < $$p) ; \
	done >> $(call log,$@) 2>&1
	touch $@

.stage.%.start: .stage.patch
	echo STAGE: $@
	#mkdir -p $(call arena,$@) > $(call log,$@) 2>&1

.stage.%.cleancross: .stage.%.start
	rm -rf $(call arena,$@)/cross

# Build expat for proper GDB support
.stage.%.expat: .stage.%.cleancross
	echo STAGE: $@
	mkdir -p $(call arena,$@)
	rm -rf $(call arena,$@)/expat > $(call log,$@) 2>&1
	cp -a $(REPODIR)/libexpat/expat $(call arena,$@)/expat >> $(call log,$@) 2>&1
	(cd $(call arena,$@)/expat && bash buildconf.sh && ./configure $(call configure,$@) --prefix=$(call arena,$@)/cross && $(MAKE) && $(MAKE) install) >> $(call log,$@) 2>&1
	touch $@

# Build GMP for proper GDB support
.stage.%.gmp: .stage.%.start
	echo STAGE: $@
	mkdir -p $(call arena,$@)
	rm -rf $(call arena,$@)/gmp $(call arena,$@)/gmp-$(GMP_VER) > $(call log,$@) 2>&1
	(cd $(call arena,$@) && tar xvf $(REPODIR)/gmp-$(GMP_VER).tar.bz2) >> $(call log,$@) 2>&1
	(cd $(call arena,$@)/gmp-$(GMP_VER); $(call setenvtgtcross,$@); ./configure $(filter-out --target=$(ARCH), $(call configure,$@)) --prefix=$(call arena,$@)/gmp && $(MAKE) && $(MAKE) install) >> $(call log,$@) 2>&1
	rm -rf $(call arena,$@)/mpfr* > $(call log,$@) 2>&1
	(cd $(call arena,$@) && tar xvf $(REPODIR)/mpfr-3.1.4.tar.bz2) >> $(call log,$@) 2>&1
	(cd $(call arena,$@)/mpfr-*; $(call setenvtgtcross,$@); ./configure $(filter-out --target=$(ARCH), $(call configure,$@)) --with-gmp=$(call arena,$@)/gmp --prefix=$(call arena,$@)/mpfr && $(MAKE) && $(MAKE) install) >> $(call log,$@) 2>&1
	touch $@

# Build GMP for proper GDB support - MacOS has linker error without --disable-assembly
.stage.MACOSX86.gmp: .stage.MACOSX86.start
.stage.MACOSARM.gmp: .stage.MACOSARM.start
.stage.MACOSX86.gmp .stage.MACOSARM.gmp:
	echo STAGE: $@
	mkdir -p $(call arena,$@)
	rm -rf $(call arena,$@)/gmp $(call arena,$@)/gmp-$(GMP_VER) > $(call log,$@) 2>&1
	(cd $(call arena,$@) && tar xvf $(REPODIR)/gmp-$(GMP_VER).tar.bz2) >> $(call log,$@) 2>&1
	(cd $(call arena,$@)/gmp-$(GMP_VER); $(call setenvtgtcross,$@); ./configure $(filter-out --target=$(ARCH), $(call configure,$@)) --prefix=$(call arena,$@)/gmp --disable-assembly && $(MAKE) && $(MAKE) install) >> $(call log,$@) 2>&1
	rm -rf $(call arena,$@)/mpfr* > $(call log,$@) 2>&1
	(cd $(call arena,$@) && tar xvf $(REPODIR)/mpfr-3.1.4.tar.bz2) >> $(call log,$@) 2>&1
	(cd $(call arena,$@)/mpfr-*; $(call setenvtgtcross,$@); ./configure $(filter-out --target=$(ARCH), $(call configure,$@)) --with-gmp=$(call arena,$@)/gmp --prefix=$(call arena,$@)/mpfr && $(MAKE) && $(MAKE) install) >> $(call log,$@) 2>&1
	touch $@

# Build ncurses for GDB
.stage.LINUX.ncurses: .stage.%.start
	echo STAGE: $@
	mkdir -p $(call arena,$@)
	rm -rf $(call arena,$@)/ncurses* > $(call log,$@) 2>&1
	(cd $(call arena,$@) && tar xvf $(BLOBS)/ncurses-6.4.tar.gz) >> $(call log,$@) 2>&1
	(cd $(call arena,$@)/ncurses-6.4 && ./configure --prefix=$(call arena,$@)/cross --without-progs --without-manpages --without-shared --with-termlib --without-tack --without-tests --disable-widec && $(MAKE) && $(MAKE) install) >> $(call log,$@) 2>&1
	touch $@

.stage.%.ncurses: .stage.%.start
	echo STAGE: $@

# Build binutils
# TODO - This is a hack.  If you have a more concise way of doing multiple passes with slightly different options, please do contribute!
binutils-config  = echo STAGE: $(1);
binutils-config += export TGT=$$(echo $(1) | cut -f2 -d_);
binutils-config += rm -rf $(call arena,$(1))/$$TGT.$(BINUTILS_DIR) > $(call log,$(1)) 2>&1;
binutils-config += mkdir -p $(call arena,$(1))/$$TGT.$(BINUTILS_DIR) >> $(call log,$(1)) 2>&1;
binutils-config += (cd $(call arena,$(1))/$$TGT.$(BINUTILS_DIR); $(call setenvtgtcross,$(1)); $(REPODIR)/$(BINUTILS_DIR)/configure --prefix=$(call arena,$(1))/$$TGT $(2) --target=$$TGT $(call configure,$(1)) --with-gmp=$(call arena,$(1))/gmp --with-mpfr=$(call arena,$(1))/mpfr --disable-sim) >> $(call log,$(1)) 2>&1;
binutils-config += touch $(1)

.stage.%.binutils-config: .stage.%.binutils-config_arm-none-eabi .stage.%.binutils-config_riscv32-unknown-elf
	echo STAGE: $@

.stage.%.binutils-config_arm-none-eabi: .stage.%.gmp .stage.%.expat .stage.%.ncurses
	$(call binutils-config,$@,--with-cpu=cortex-m0plus --with-no-thumb-interwork)

.stage.%.binutils-config_riscv32-unknown-elf: .stage.%.gmp .stage.%.expat .stage.%.ncurses
	$(call binutils-config,$@,--with-arch=rv32imac)

# $(MAKE) in a $(call) block doesn't seem to pass in the parallel options, so need to explicitly call the $(MAKE) inside each target (cut-n-paste!)
#binutils-make  = echo STAGE: $(1);
#binutils-make += export TGT=$$(echo $(1) | cut -f2 -d_);
#binutils-make += (cd $(call arena,$(1))/$$TGT.$(BINUTILS_DIR); $(call setenv,$(1)); export LDFLAGS="$$LDFLAGS -static"; $(MAKE) -j2 LSSP=$(call lssp,$(1))) > $(call log,$(1)) 2>&1

.stage.%.binutils-make: .stage.%.binutils-make_arm-none-eabi .stage.%.binutils-make_riscv32-unknown-elf
	echo STAGE: $@

.stage.%.binutils-make_arm-none-eabi: .stage.%.binutils-config_arm-none-eabi
	echo STAGE: $@
	(TGT=$$(echo $@ | cut -f2 -d_); cd $(call arena,$@)/$$TGT.$(BINUTILS_DIR); $(call setenvtgtcross,$@); export LDFLAGS="$$LDFLAGS -static"; $(MAKE) LSSP=$(call lssp,$@)) > $(call log,$@) 2>&1

.stage.%.binutils-make_riscv32-unknown-elf: .stage.%.binutils-config_riscv32-unknown-elf
	echo STAGE: $@
	(TGT=$$(echo $@ | cut -f2 -d_); cd $(call arena,$@)/$$TGT.$(BINUTILS_DIR); $(call setenvtgtcross,$@); export LDFLAGS="$$LDFLAGS -static"; $(MAKE) LSSP=$(call lssp,$@)) > $(call log,$@) 2>&1

.stage.LINUX.binutils-gdbrelink: .stage.LINUX.binutils-make
	# Replace any termcap(tinfo) with the static lib instead
	sed -i 's/-ltermcap/..\/..\/cross\/lib\/libtinfo.a/' $(call arena,$@)/arm-none-eabi.$(BINUTILS_DIR)/gdb/Makefile > $(call log,$@) 2>&1
	(TGT=$$(echo $@ | cut -f2 -d_); cd $(call arena,$@)/arm-none-eabi.$(BINUTILS_DIR)/gdb && rm -f ./gdb && $(call setenvtgtcross,$@) && $(MAKE)) >> $(call log,$@) 2>&1
	sed -i 's/-ltermcap/..\/..\/cross\/lib\/libtinfo.a/' $(call arena,$@)/riscv32-unknown-elf.$(BINUTILS_DIR)/gdb/Makefile > $(call log,$@) 2>&1
	(TGT=$$(echo $@ | cut -f2 -d_); cd $(call arena,$@)/riscv32-unknown-elf.$(BINUTILS_DIR)/gdb && rm -f ./gdb && $(call setenvtgtcross,$@) && $(MAKE)) >> $(call log,$@) 2>&1

.stage.%.binutils-gdbrelink: .stage.%.binutils-make
	echo STAGE: $@

.stage.%.binutils-install: .stage.%.binutils-gdbrelink
	(TGT=arm-none-eabi; cd $(call arena,$@)/arm-none-eabi.$(BINUTILS_DIR); $(call setenvtgtcross,$@); $(MAKE) install) > $(call log,$@) 2>&1
	(TGT=arm-none-eabi; cd $(call arena,$@)/arm-none-eabi/bin; ln -sf arm-none-eabi-gcc$(call exe,$@) arm-none-eabi-cc$(call exe,$@)) >> $(call log,$@) 2>&1
	(TGT=riscv32-unknown-elf; cd $(call arena,$@)/riscv32-unknown-elf.$(BINUTILS_DIR); $(call setenvtgtcross,$@); $(MAKE) install) > $(call log,$@) 2>&1
	(TGT=riscv32-unknown-elf; cd $(call arena,$@)/riscv32-unknown-elf/bin; ln -sf riscv32-unknown-elf-gcc$(call exe,$@) riscv32-unknown-elf-cc$(call exe,$@)) >> $(call log,$@) 2>&1
	touch $@

# Copy certain DLLs needed by GDB for Windows installations, no-op otherwise
.stage.WIN32.binutils-post: .stage.WIN32.binutils-install
	echo STAGE: $@ - copying GDB support files
	cp /usr/lib/gcc/i686-w64-mingw32/*-posix/libgcc_s_sjlj-1.dll /usr/lib/gcc/i686-w64-mingw32/*-posix/libstdc++-6.dll /usr/i686-w64-mingw32/lib/libwinpthread-1.dll $(call arena,$@)/arm-none-eabi/bin >> $(call log,$@) 2>&1
	cp /usr/lib/gcc/i686-w64-mingw32/*-posix/libgcc_s_sjlj-1.dll /usr/lib/gcc/i686-w64-mingw32/*-posix/libstdc++-6.dll /usr/i686-w64-mingw32/lib/libwinpthread-1.dll $(call arena,$@)/riscv32-unknown-elf/bin >> $(call log,$@) 2>&1

.stage.WIN64.binutils-post: .stage.WIN64.binutils-install
	echo STAGE: $@ - copying GDB support files
	cp /usr/lib/gcc/x86_64-w64-mingw32/*-posix/libgcc_s_seh-1.dll /usr/lib/gcc/x86_64-w64-mingw32/*-posix/libstdc++-6.dll /usr/x86_64-w64-mingw32/lib/libwinpthread-1.dll $(call arena,$@)/arm-none-eabi/bin >> $(call log,$@) 2>&1
	cp /usr/lib/gcc/x86_64-w64-mingw32/*-posix/libgcc_s_seh-1.dll /usr/lib/gcc/x86_64-w64-mingw32/*-posix/libstdc++-6.dll /usr/x86_64-w64-mingw32/lib/libwinpthread-1.dll $(call arena,$@)//riscv32-unknown-elf/bin >> $(call log,$@) 2>&1

.stage.%.binutils-post: .stage.%.binutils-install
	echo STAGE: $@

gcc1-config  = echo STAGE: $(1);
gcc1-config += export TGT=$$(echo $(1) | cut -f2 -d_);
gcc1-config += rm -rf $(call arena,$(1))/$$TGT.$(GCC_DIR) > $(call log,$(1)) 2>&1;
gcc1-config += mkdir -p $(call arena,$(1))/$$TGT.$(GCC_DIR) >> $(call log,$(1)) 2>&1;
gcc1-config += (cd $(call arena,$(1))/$$TGT.$(GCC_DIR); $(call setenvtgtcross,$(1)); $(REPODIR)/$(GCC_DIR)/configure $(2) --prefix=$(call arena,$(1))/$$TGT --target=$$TGT $(call configure,$(1))) >> $(call log,$(1)) 2>&1;
gcc1-config += touch $(1)

.stage.%.gcc1-config: .stage.%.gcc1-config_arm-none-eabi .stage.%.gcc1-config_riscv32-unknown-elf
	echo STAGE: $@

.stage.%.gcc1-config_arm-none-eabi: .stage.%.binutils-post
	$(call gcc1-config,$@,--with-cpu=cortex-m0plus --with-no-thumb-interwork)

.stage.%.gcc1-config_riscv32-unknown-elf: .stage.%.binutils-post
	$(call gcc1-config,$@,)

#gcc1-make  = echo STAGE: $(1);
#gcc1-make += export TGT=$$(echo $(1) | cut -f2 -d_);
#gcc1-make += (cd $(call arena,$(1))/$$TGT.$(GCC_DIR); $(call setenv,$(1)); $(MAKE) all-gcc) > $(call log,$(1)) 2>&1;
gcc1-make2 += (TGT=$$(echo $(1) | cut -f2 -d_); cd $(call arena,$(1))/$$TGT.$(GCC_DIR); $(call setenvtgtcross,$(1)); $(MAKE) install-gcc) >> $(call log,$(1)) 2>&1;
gcc1-make2 += touch $(1)

.stage.%.gcc1-make: .stage.%.gcc1-make_arm-none-eabi .stage.%.gcc1-make_riscv32-unknown-elf
	echo STAGE: $@

.stage.%.gcc1-make_arm-none-eabi: .stage.%.gcc1-config
	echo STAGE: $@
	(TGT=$$(echo $@ | cut -f2 -d_); cd $(call arena,$@)/$$TGT.$(GCC_DIR); $(call setenvtgtcross,$@); $(MAKE) all-gcc) > $(call log,$@) 2>&1;
	$(call gcc1-make2,$@)

.stage.%.gcc1-make_riscv32-unknown-elf: .stage.%.gcc1-config
	echo STAGE: $@
	(TGT=$$(echo $@ | cut -f2 -d_); cd $(call arena,$@)/$$TGT.$(GCC_DIR); $(call setenvtgtcross,$@); $(MAKE) all-gcc) > $(call log,$@) 2>&1;
	$(call gcc1-make2,$@)


newlib-conf  = echo STAGE: $(1);
newlib-conf += export TGT=$$(echo $(1) | cut -f2 -d_);
newlib-conf += rm -rf $(call arena,$(1))/$$TGT.newlib > $(call log,$(1)) 2>&1;
newlib-conf += mkdir -p $(call arena,$(1))/$$TGT.newlib >> $(call log,$(1)) 2>&1;
newlib-conf += (cd $(call arena,$(1))/$$TGT.newlib; $(call setenvtgtcross,$(1)); $(REPODIR)/newlib/configure $(2) --prefix=$(call arena,$(1))/$$TGT --target=$$TGT $(CONFIGURENEWLIBCOM)) >> $(call log,$(1)) 2>&1;
newlib-conf += touch $(1)

.stage.%.newlib-config: .stage.%.newlib-config_arm-none-eabi .stage.%.newlib-config_riscv32-unknown-elf
	echo STAGE: $@

.stage.%.newlib-config_arm-none-eabi: .stage.%.gcc1-make
	$(call newlib-conf,$@,--with-cpu=cortex-m0plus --with-no-thumb-interwork)

.stage.%.newlib-config_riscv32-unknown-elf: .stage.%.gcc1-make
	$(call newlib-conf,$@,)

.stage.%.newlib-make: .stage.%.newlib-make_arm-none-eabi .stage.%.newlib-make_riscv32-unknown-elf
	echo STAGE: $@

.stage.%.newlib-make_arm-none-eabi: .stage.%.newlib-config
	echo STAGE: $@
	(TGT=$$(echo $@ | cut -f2 -d_); cd $(call arena,$@)/$$TGT.newlib; $(call setenvtgtcross,$@); $(MAKE)) > $(call log,$@) 2>&1
	(TGT=$$(echo $@ | cut -f2 -d_); cd $(call arena,$@)/$$TGT.newlib; $(call setenvtgtcross,$@); $(MAKE) install -j1) >> $(call log,$@) 2>&1
	touch $@

.stage.%.newlib-make_riscv32-unknown-elf: .stage.%.newlib-config
	echo STAGE: $@
	(TGT=$$(echo $@ | cut -f2 -d_); cd $(call arena,$@)/$$TGT.newlib; $(call setenvtgtcross,$@); $(MAKE)) > $(call log,$@) 2>&1
	(TGT=$$(echo $@ | cut -f2 -d_); cd $(call arena,$@)/$$TGT.newlib; $(call setenvtgtcross,$@); $(MAKE) install -j1) >> $(call log,$@) 2>&1
	touch $@

.stage.%.libstdcpp:.stage.%.libstdcpp_arm-none-eabi .stage.%.libstdcpp_riscv32-unknown-elf
	echo STAGE: $@

.stage.%.libstdcpp_arm-none-eabi: .stage.%.newlib-make
	echo STAGE: $@
	# stage 2 (build libstdc++)
	(TGT=$$(echo $@ | cut -f2 -d_); cd $(call arena,$@)/$$TGT.$(GCC_DIR); $(call setenvtgtcross,$@); $(MAKE)) > $(call log,$@) 2>&1
	(TGT=$$(echo $@ | cut -f2 -d_); cd $(call arena,$@)/$$TGT.$(GCC_DIR); $(call setenvtgtcross,$@); $(MAKE) install) >> $(call log,$@) 2>&1
	touch $@

.stage.%.libstdcpp_riscv32-unknown-elf: .stage.%.newlib-make
	echo STAGE: $@
	# stage 2 (build libstdc++)
	(TGT=$$(echo $@ | cut -f2 -d_); cd $(call arena,$@)/$$TGT.$(GCC_DIR); $(call setenvtgtcross,$@); $(MAKE)) > $(call log,$@) 2>&1
	(TGT=$$(echo $@ | cut -f2 -d_); cd $(call arena,$@)/$$TGT.$(GCC_DIR); $(call setenvtgtcross,$@); $(MAKE) install) >> $(call log,$@) 2>&1
	touch $@

.stage.%.libstdcpp-nox: .stage.%.libstdcpp-nox_arm-none-eabi .stage.%.libstdcpp-nox_riscv32-unknown-elf
	echo STAGE: $@

.stage.%.libstdcpp-nox_arm-none-eabi: .stage.%.libstdcpp
	echo STAGE: $@
	export TGT=$$(echo $@ | cut -f2 -d_)
	# We copy existing stdc, adjust the makefile, and build a single .a to save much time
	export TGT=$$(echo $@ | cut -f2 -d_); cp $(call arena,$@)/$$TGT/$$TGT/lib/thumb/libstdc++.a $(call arena,$@)/$$TGT/$$TGT/lib/thumb/libstdc++-exc.a >> $(call log,$@) 2>&1
	export TGT=$$(echo $@ | cut -f2 -d_); rm -rf $(call arena,$@)/$$TGT.$(GCC_DIR)/$$TGT/libstdc++-v3-nox > $(call log,$@) 2>&1
	export TGT=$$(echo $@ | cut -f2 -d_); cp -a $(call arena,$@)/$$TGT.$(GCC_DIR)/$$TGT/libstdc++-v3 $(call arena,$@)/$$TGT.$(GCC_DIR)/$$TGT/libstdc++-v3-nox >> $(call log,$@) 2>&1
	(export TGT=$$(echo $@ | cut -f2 -d_); cd $(call arena,$@)/$$TGT.$(GCC_DIR)/$$TGT/libstdc++-v3-nox; $(call setenvtgtcross,$@); $(MAKE) clean; find . -name Makefile -exec sed -i 's/-free/-free -fno-exceptions/' \{\} \; ; $(MAKE)) >> $(call log,$@) 2>&1
	export TGT=$$(echo $@ | cut -f2 -d_); cp $(call arena,$@)/$$TGT.$(GCC_DIR)/$$TGT/libstdc++-v3-nox/src/.libs/libstdc++.a $(call arena,$@)/$$TGT/$$TGT/lib/thumb/libstdc++.a >> $(call log,$@) 2>&1
	touch $@

.stage.%.libstdcpp-nox_riscv32-unknown-elf: .stage.%.libstdcpp
	echo STAGE: $@
	export TGT=$$(echo $@ | cut -f2 -d_)
	# We copy existing stdc, adjust the makefile, and build a single .a to save much time
	export TGT=$$(echo $@ | cut -f2 -d_); cp $(call arena,$@)/$$TGT/$$TGT/lib/rv32imac/ilp32/libstdc++.a $(call arena,$@)/$$TGT/$$TGT/lib/rv32imac/ilp32/libstdc++-exc.a >> $(call log,$@) 2>&1
	export TGT=$$(echo $@ | cut -f2 -d_); rm -rf $(call arena,$@)/$$TGT.$(GCC_DIR)/$$TGT/libstdc++-v3-nox > $(call log,$@) 2>&1
	export TGT=$$(echo $@ | cut -f2 -d_); cp -a $(call arena,$@)/$$TGT.$(GCC_DIR)/$$TGT/libstdc++-v3 $(call arena,$@)/$$TGT.$(GCC_DIR)/$$TGT/libstdc++-v3-nox >> $(call log,$@) 2>&1
	(export TGT=$$(echo $@ | cut -f2 -d_); cd $(call arena,$@)/$$TGT.$(GCC_DIR)/$$TGT/libstdc++-v3-nox; $(call setenvtgtcross,$@); $(MAKE) clean; find . -name Makefile -exec sed -i 's/-free/-free -fno-exceptions -march=rv32imac_zicsr_zifencei_zba_zbb_zbs_zbkb -mabi=ilp32/' \{\} \; ; $(MAKE)) >> $(call log,$@) 2>&1
	export TGT=$$(echo $@ | cut -f2 -d_); cp $(call arena,$@)/$$TGT.$(GCC_DIR)/$$TGT/libstdc++-v3-nox/src/.libs/libstdc++.a $(call arena,$@)/$$TGT/$$TGT/lib/rv32imac/ilp32/libstdc++.a >> $(call log,$@) 2>&1
	touch $@

.stage.MACOSARM.strip: .stage.MACOSARM.libstdcpp-nox
	echo STAGE: $@
	# STRIP breaks the app on M1s
	touch $@

.stage.%.strip: .stage.%.libstdcpp-nox
	echo STAGE: $@
	for TGT in arm-none-eabi riscv32-unknown-elf; do ($(call setenvtgtcross,$@); $(call host,$@)-strip $(call arena,$@)/$$TGT/bin/*$(call exe,$@) $(call arena,$@)/$$TGT/libexec/gcc/$$TGT/*/c*$(call exe,$@) || true ) ; done > $(call log,$@) 2>&1
	touch $@

.stage.%.post: .stage.%.strip
	echo STAGE: $@
	for sh in post/$(GCC)*.sh; do \
	    test -r "$${sh}" || continue ; \
            [ -x "$${sh}" ] && $${sh} $(call ext,$@) ; \
	done > $(call log,$@) 2>&1
	touch $@

.stage.%.package: .stage.%.package_arm-none-eabi .stage.%.package_riscv32-unknown-elf
	echo STAGE: $@

.stage.%.package_arm-none-eabi: .stage.%.post
	echo STAGE: $@
	export TGT=$$(echo $@ | cut -f2 -d_)
	rm -rf pkg.$(call arch,$@) > $(call log,$@) 2>&1
	mkdir -p pkg.$(call arch,$@) >> $(call log,$@) 2>&1
	export TGT=$$(echo $@ | cut -f2 -d_); cp -a $(call arena,$@)/$$TGT pkg.$(call arch,$@)/$$TGT >> $(call log,$@) 2>&1
	(export TGT=$$(echo $@ | cut -f2 -d_); cd pkg.$(call arch,$@)/$$TGT; $(call setenvtgtcross,$@); pkgdesc="$$TGT-gcc"; pkgname="toolchain-rp2040-earlephilhower"; $(call makepackagejson,$@)) >> $(call log,$@) 2>&1
	(export TGT=$$(echo $@ | cut -f2 -d_); tarball=$(call host,$@).$$TGT-$$(git rev-parse --short HEAD).$(STAMP).$(call tarext,$@) ; \
	    cd pkg.$(call arch,$@) && cp -a $(PATCHDIR) $$TGT/. && $(call makegitlog) > $$TGT/gitlog.txt && $(call tarcmd,$@) $(call taropt,$@) ../$${tarball} $$TGT/ ; cd ..; $(call makejson,$@)) >> $(call log,$@) 2>&1
	rm -rf pkg.$(call arch,$@) >> $(call log,$@) 2>&1
	touch $@

.stage.%.package_riscv32-unknown-elf: .stage.%.post
	echo STAGE: $@
	export TGT=$$(echo $@ | cut -f2 -d_)
	rm -rf pkgb.$(call arch,$@) > $(call log,$@) 2>&1
	mkdir -p pkgb.$(call arch,$@) >> $(call log,$@) 2>&1
	export TGT=$$(echo $@ | cut -f2 -d_); cp -a $(call arena,$@)/$$TGT pkgb.$(call arch,$@)/$$TGT >> $(call log,$@) 2>&1
	for i in rv32i rv32iac rv32im rv32imafc rv64imac rv64imafdc; do rm -r pkgb.$(call arch,$@)/riscv32-unknown-elf/riscv32-unknown-elf/lib/$$i; done >> $(call log,$@) 2>&1
	(export TGT=$$(echo $@ | cut -f2 -d_); cd pkgb.$(call arch,$@)/$$TGT; $(call setenvtgtcross,$@); pkgdesc="$$TGT-gcc"; pkgname="toolchain-rp2040-earlephilhower-riscv"; $(call makepackagejson,$@)) >> $(call log,$@) 2>&1
	(export TGT=$$(echo $@ | cut -f2 -d_); tarball=$(call host,$@).$$TGT-$$(git rev-parse --short HEAD).$(STAMP).$(call tarext,$@) ; \
	    cd pkgb.$(call arch,$@) && cp -a $(PATCHDIR) $$TGT/. && $(call makegitlog) > $$TGT/gitlog.txt && $(call tarcmd,$@) $(call taropt,$@) ../$${tarball} $$TGT/ ; cd ..; $(call makejson,$@)) >> $(call log,$@) 2>&1
	rm -rf pkgb.$(call arch,$@) >> $(call log,$@) 2>&1
	touch $@

.stage.%.mklittlefs: .stage.%.start
	echo STAGE: $@
	rm -rf $(call arena,$@)/mklittlefs > $(call log,$@) 2>&1
	cp -a $(REPODIR)/mklittlefs $(call arena,$@)/mklittlefs >> $(call log,$@) 2>&1
	# Dependencies borked in mklittlefs makefile, so don't use parallel make
	(cd $(call arena,$@)/mklittlefs;\
	    $(call setenvtgtcross,$@); \
	    TARGET_OS=$(call mktgt,$@) CC=$(call host,$@)-gcc CXX=$(call host,$@)-g++ STRIP=touch $(call over,$@) \
            make -j1 clean mklittlefs$(call exe,$@) BUILD_CONFIG_NAME="-arduino-rpipico") >> $(call log,$@) 2>&1
	rm -rf pkg.mklittlefs.$(call arch,$@) >> $(call log,$@) 2>&1
	mkdir -p pkg.mklittlefs.$(call arch,$@)/mklittlefs >> $(call log,$@) 2>&1
	(cd pkg.mklittlefs.$(call arch,$@)/mklittlefs; $(call setenvtgtcross,$@); pkgdesc="littlefs-utility"; pkgname="tool-mklittlefs-rp2040-earlephilhower"; $(call makepackagejson,$@)) >> $(call log,$@) 2>&1
	cp $(call arena,$@)/mklittlefs/mklittlefs$(call exe,$@) pkg.mklittlefs.$(call arch,$@)/mklittlefs/. >> $(call log,$@) 2>&1
	(tarball=$(call host,$@).mklittlefs-$$(cd $(REPODIR)/mklittlefs && git rev-parse --short HEAD).$(STAMP).$(call tarext,$@) ; \
	    cd pkg.mklittlefs.$(call arch,$@) && $(call makegitlog) > mklittlefs/gitlog.txt && $(call tarcmd,$@) $(call taropt,$@) ../$${tarball} mklittlefs; cd ..; $(call makejson,$@)) >> $(call log,$@) 2>&1
	rm -rf pkg.mklittlefs.$(call arch,$@) >> $(call log,$@) 2>&1
	touch $@

.stage.%.pioasm: .stage.%.start
	echo STAGE: $@
	rm -rf $(call arena,$@)/pioasm > $(call log,$@) 2>&1
	mkdir $(call arena,$@)/pioasm >> $(call log,$@) 2>&1
	(cd $(REPODIR)/pico-sdk/tools/pioasm; CXX=$(call host,$@)-g++ $(call over,$@); $$CXX -std=gnu++11 -o $(call arena,$@)/pioasm/pioasm$(call exe,$@) main.cpp pio_assembler.cpp pio_disassembler.cpp gen/lexer.cpp gen/parser.cpp c_sdk_output.cpp python_output.cpp hex_output.cpp -Igen/ -I. $(call static, $@)) >> $(call log,$@) 2>&1
	rm -rf pkg.pioasm.$(call arch,$@) >> $(call log,$@) 2>&1
	mkdir -p pkg.pioasm.$(call arch,$@)/pioasm >> $(call log,$@) 2>&1
	(cd pkg.pioasm.$(call arch,$@)/pioasm; $(call setenvtgtcross,$@); pkgdesc="pioasm-utility"; pkgname="tool-pioasm-rp2040-earlephilhower"; $(call makepackagejson,$@)) >> $(call log,$@) 2>&1
	#$(call host,$@)-strip $(call arena,$@)/pioasm/pioasm$(call exe,$@) >> $(call log,$@) 2>&1
	cp $(call arena,$@)/pioasm/pioasm$(call exe,$@) pkg.pioasm.$(call arch,$@)/pioasm/. >> $(call log,$@) 2>&1
	(tarball=$(call host,$@).pioasm-$$(cd $(REPODIR)/pico-sdk && git rev-parse --short HEAD).$(STAMP).$(call tarext,$@) ; \
	    cd pkg.pioasm.$(call arch,$@) && $(call makegitlog) > pioasm/gitlog.txt && $(call tarcmd,$@) $(call taropt,$@) ../$${tarball} pioasm; cd ..; $(call makejson,$@)) >> $(call log,$@) 2>&1
	rm -rf pkg.pioasm.$(call arch,$@) >> $(call log,$@) 2>&1
	touch $@

.stage.LINUX.picotool-prep: .stage.LINUX.start
	echo STAGE: $@
	rm -rf $(call arena,$@)/picotool > $(call log,$@) 2>&1
	mkdir $(call arena,$@)/picotool >> $(call log,$@) 2>&1
	# Make libusb.a static, which means we ned to manually list the pthrread and udev dependencies
	(cd $(call arena,$@)/picotool; PICO_SDK_PATH=$(REPODIR)/pico-sdk cmake $(REPODIR)/picotool -DCMAKE_CXX_STANDARD_LIBRARIES=/lib/x86_64-linux-gnu/libudev.so.1 -DCMAKE_EXE_LINKER_FLAGS_INIT="-pthread" -DLIBUSB_LIBRARIES="/usr/lib/x86_64-linux-gnu/libusb-1.0.a") >> $(call log,$@) 2>&1

.stage.ARM64.picotool-prep: .stage.ARM64.start
.stage.RPI.picotool-prep: .stage.RPI.start
.stage.LINUX32.picotool-prep: .stage.LINUX32.start
.stage.ARM64.picotool-prep .stage.RPI.picotool-prep .stage.LINUX32.picotool-prep:
	echo STAGE: $@
	rm -rf $(call arena,$@)/picotool > $(call log,$@) 2>&1
	(mkdir $(call arena,$@)/picotool; cd $(call arena,$@)/picotool; for i in $(BLOBS)/*_$(call deb, $@).deb; do ar x $$i; tar xvf data.tar.xz; done) >> $(call log,$@) 2>&1
	(if [ -e $(call arena,$@)/picotool/lib/i386-linux-gnu ]; then mv $(call arena,$@)/picotool/lib/i386-linux-gnu $(call arena,$@)/picotool/lib/i686-linux-gnu; fi) 2>&1
	(if [ -e $(call arena,$@)/picotool/usr/lib/i386-linux-gnu ]; then mv $(call arena,$@)/picotool/usr/lib/i386-linux-gnu $(call arena,$@)/picotool/usr/lib/i686-linux-gnu; fi) 2>&1
	(for i in $(call arena,$@)/picotool/usr/lib/$(call host,$@)/pkgconfig/*.pc; do sed -i 's@^prefix=.*@prefix=$(call arena,$@)/usr@' $$i; done) >> $(call log,$@) 2>&1
	echo "set(CMAKE_SYSTEM_NAME Linux)\nset(CMAKE_C_COMPILER $(call host,$@)-gcc)\nset(CMAKE_CXX_COMPILER $(call host,$@)-g++)\nset(CMAKE_FIND_ROOT_PATH /usr/$(call host,$@))\nset(CMAKE_FIND_ROOT_PATH_MODE_PROGRAM NEVER)\nset(CMAKE_FIND_ROOT_PATH_MODE_LIBRARY ONLY)\nset(CMAKE_FIND_ROOT_PATH_MODE_INCLUDE ONLY)\n" > $(call arena,$@)/picotool.cross.cmake
	(cd $(call arena,$@)/picotool; PICO_SDK_PATH=$(REPODIR)/pico-sdk cmake -DCMAKE_TOOLCHAIN_FILE=$(call arena,$@)/picotool.cross.cmake -DLIBUSB_LIBRARIES="-L$(call arena,$@)/picotool/usr/lib/$(call host,$@);-L$(call arena,$@)/picotool/lib/$(call host,$@);-lusb-1.0;-ludev;-pthread" -DLIBUSB_INCLUDE_DIR=$(call arena,$@)/usr/include/libusb-1.0/ $(REPODIR)/picotool) >> $(call log,$@) 2>&1

.stage.%.picotool: .stage.%.picotool-prep
	echo STAGE: $@
	(cd $(call arena,$@)/picotool && $(MAKE) && mkdir -p $(call arena,$@)/pkg.picotool.$(call arch,$@)/picotool && cp picotool $(REPODIR)/picotool/LICENSE.TXT $(call arena,$@)/pkg.picotool.$(call arch,$@)/picotool/.) >> $(call log,$@) 2>&1
	(cd $(call arena,$@)/pkg.picotool.$(call arch,$@)/picotool; $(call setenvtgtcross,$@); pkgdesc="picotool-utility"; pkgname="tool-picotool-rp2040-earlephilhower"; $(call makepackagejson,$@)) >> $(call log,$@) 2>&1
	(tarball=$(call host,$@).picotool-$$(cd $(REPODIR)/picotool && git rev-parse --short HEAD).$(STAMP).$(call tarext,$@) ; \
	    cd $(call arena,$@)/pkg.picotool.$(call arch,$@) && $(call makegitlog) > picotool/gitlog.txt && $(call tarcmd,$@) $(call taropt,$@) ../../$${tarball} picotool; cd ../..; $(call makejson,$@)) >> $(call log,$@) 2>&1
	rm -rf $(call arena,$@)/pkg.picotool.$(call arch,$@) >> $(call log,$@) 2>&1
	touch $@

# These archs use manually build picotool executables
.stage.WIN32.picotool: .stage.WIN32.start
.stage.WIN64.picotool: .stage.WIN64.start
.stage.MACOSX86.picotool: .stage.MACOSX86.start
.stage.MACOSARM.picotool: .stage.MACOSARM.start
.stage.WIN32.picotool .stage.WIN64.picotool .stage.MACOSX86.picotool .stage.MACOSARM.picotool:
	echo STAGE: $@
	rm -rf $(call arena,$@)/picotool > $(call log,$@) 2>&1
	mkdir -p pkg.picotool.$(call arch,$@) >> $(call log,$@) 2>&1
	(cd pkg.picotool.$(call arch,$@); tar xf $(BLOBS)/picotool$(call ext,$@).tar.gz) >> $(call log,$@) 2>&1
	(cd pkg.picotool.$(call arch,$@)/picotool; $(call setenvtgtcross,$@); pkgdesc="picotool-utility"; pkgname="tool-picotool-rp2040-earlephilhower"; $(call makepackagejson,$@)) >> $(call log,$@) 2>&1
	(tarball=$(call host,$@).picotool-$$(cd $(REPODIR)/picotool && git rev-parse --short HEAD).$(STAMP).$(call tarext,$@) ; \
	    cd pkg.picotool.$(call arch,$@) && $(call tarcmd,$@) $(call taropt,$@) ../$${tarball} picotool; cd ..; $(call makejson,$@)) >> $(call log,$@) 2>&1
	rm -rf pkg.picotool.$(call arch,$@) >> $(call log,$@) 2>&1
	touch $@

.stage.ARM64.openocd-prep: .stage.ARM64.start
.stage.RPI.openocd-prep: .stage.RPI.start
.stage.ARM64.openocd-prep .stage.RPI.openocd-prep:
	echo STAGE: $@
	rm -rf $(call arena,$@)/openocd > $(call log,$@) 2>&1
	cp -a $(REPODIR)/openocd $(call arena,$@)/openocd >> $(call log,$@) 2>&1
	(cd $(call arena,$@); for i in $(BLOBS)/*_$(call deb, $@).deb; do ar x $$i; tar xvf data.tar.xz; done) >> $(call log,$@) 2>&1
	(cd $(call arena,$@)/usr/lib/*; rm ./libhidapi-hidraw.so* ./libhidapi-libusb.so*) >> $(call log,$@) 2>&1
	(for i in $(call arena,$@)/usr/lib/$(call host,$@)/pkgconfig/*.pc; do sed -i 's@^prefix=.*@prefix=$(call arena,$@)/usr@' $$i; done) >> $(call log,$@) 2>&1
	(echo cp $(call arena,$@)/lib/$(call host,$@)/* $(call arena,$@)/usr/lib/$(call host,$@)/.) >> $(call log,$@) 2>&1
	(cp $(call arena,$@)/lib/$(call host,$@)/* $(call arena,$@)/usr/lib/$(call host,$@)/.) >> $(call log,$@) 2>&1
	(cd $(call arena,$@)/openocd; PKG_CONFIG_PATH=$(call arena,$@)/usr/lib/$(call host,$@)/pkgconfig LIBS="-ludev -lpthread" LDFLAGS=-L$(call arena,$@)/lib/$(call host,$@) \
         ./configure $(CONFIGOPENOCD) --prefix $(call arena,$@)/pkg.openocd.$(call arch,$@)/openocd --host=$(call host,$@)) >> $(call log,$@) 2>&1

.stage.LINUX32.openocd-prep: .stage.LINUX32.start
	echo STAGE: $@
	rm -rf $(call arena,$@)/openocd > $(call log,$@) 2>&1
	cp -a $(REPODIR)/openocd $(call arena,$@)/openocd >> $(call log,$@) 2>&1
	(cd $(call arena,$@); for i in $(BLOBS)/*_$(call deb, $@).deb; do ar x $$i; tar xvf data.tar.xz; done) >> $(call log,$@) 2>&1
	(cd $(call arena,$@)/usr/lib/*; rm ./libhidapi-hidraw.so* ./libhidapi-libusb.so*) >> $(call log,$@) 2>&1
	(for i in $(call arena,$@)/usr/lib/i386-linux-gnu/pkgconfig/*.pc; do sed -i 's@^prefix=.*@prefix=$(call arena,$@)/usr@' $$i; done) >> $(call log,$@) 2>&1
	(cp $(call arena,$@)/lib/i386-linux-gnu/* $(call arena,$@)/usr/lib/i386-linux-gnu/.) >> $(call log,$@) 2>&1
	(cd $(call arena,$@)/openocd; PKG_CONFIG_PATH=$(call arena,$@)/usr/lib/i386-linux-gnu/pkgconfig LIBS="-ludev -lpthread" LDFLAGS=-L$(call arena,$@)/lib/i386-linux-gnu \
         ./configure $(CONFIGOPENOCD) --prefix $(call arena,$@)/pkg.openocd.$(call arch,$@)/openocd --host=$(call host,$@)) >> $(call log,$@) 2>&1

.stage.LINUX.openocd-prep: .stage.LINUX.start
	echo STAGE: $@
	rm -rf $(call arena,$@)/openocd > $(call log,$@) 2>&1
	cp -a $(REPODIR)/openocd $(call arena,$@)/openocd >> $(call log,$@) 2>&1
	(cd $(call arena,$@)/openocd; ./configure $(CONFIGOPENOCD) --prefix $(call arena,$@)/pkg.openocd.$(call arch,$@)/openocd) >> $(call log,$@) 2>&1

# These archs use manually build openocd executables
.stage.WIN32.openocd: .stage.WIN32.start
.stage.WIN64.openocd: .stage.WIN64.start
.stage.MACOSX86.openocd: .stage.MACOSX86.start
.stage.MACOSARM.openocd: .stage.MACOSARM.start
.stage.WIN32.openocd .stage.WIN64.openocd .stage.MACOSX86.openocd .stage.MACOSARM.openocd:
	echo STAGE: $@
	rm -rf $(call arena,$@)/openocd > $(call log,$@) 2>&1
	mkdir -p pkg.openocd.$(call arch,$@) >> $(call log,$@) 2>&1
	(cd pkg.openocd.$(call arch,$@); tar xf $(BLOBS)/openocd$(call ext,$@).tar.gz) >> $(call log,$@) 2>&1
	(cd pkg.openocd.$(call arch,$@)/openocd; $(call setenvtgtcross,$@); pkgdesc="openocd-utility"; pkgname="tool-openocd-rp2040-earlephilhower"; $(call makepackagejson,$@)) >> $(call log,$@) 2>&1
	(tarball=$(call host,$@).openocd-$$(cd $(REPODIR)/openocd && git rev-parse --short HEAD).$(STAMP).$(call tarext,$@) ; \
	    cd pkg.openocd.$(call arch,$@) && $(call tarcmd,$@) $(call taropt,$@) ../$${tarball} openocd; cd ..; $(call makejson,$@)) >> $(call log,$@) 2>&1
	rm -rf pkg.openocd.$(call arch,$@) >> $(call log,$@) 2>&1
	touch $@

.stage.%.openocd: .stage.%.openocd-prep
	echo STAGE: $@
	(cd $(call arena,$@)/openocd && $(MAKE)) >> $(call log,$@) 2>&1
	# Hack to rebuild with static libs only for x86_64.  All others already configured properly
	if [ $(call host,$@) = x86_64-linux-gnu ]; then (cd $(call arena,$@)/openocd && gcc -pthread -Wall -Wstrict-prototypes -Wformat-security -Wshadow -Wextra -Wno-unused-parameter -Wbad-function-cast -Wcast-align -Wredundant-decls -Wpointer-arith -Wundef -g -O2 -o src/openocd src/main.o  src/.libs/libopenocd.a ./jimtcl/libjim.a -lutil -ldl /usr/lib/x86_64-linux-gnu/libhidapi-hidraw.a /usr/lib/x86_64-linux-gnu/libusb-1.0.a /lib/x86_64-linux-gnu/libudev.so.1); fi >> $(call log,$@) 2>&1
	(cd $(call arena,$@)/openocd && $(MAKE) install) >> $(call log,$@) 2>&1
	(cd $(call arena,$@)/pkg.openocd.$(call arch,$@)/openocd; $(call setenvtgtcross,$@); pkgdesc="openocd-utility"; pkgname="tool-openocd-rp2040-earlephilhower"; $(call makepackagejson,$@)) >> $(call log,$@) 2>&1
	(tarball=$(call host,$@).openocd-$$(cd $(REPODIR)/openocd && git rev-parse --short HEAD).$(STAMP).$(call tarext,$@) ; \
	    cd $(call arena,$@)/pkg.openocd.$(call arch,$@) && $(call makegitlog) > openocd/gitlog.txt && cp -a $(PATCHDIR) openocd/. && $(call tarcmd,$@) $(call taropt,$@) ../../$${tarball} openocd; cd ../..; $(call makejson,$@)) >> $(call log,$@) 2>&1
	rm -rf $(call arena,$@)/pkg.openocd.$(call arch,$@) >> $(call log,$@) 2>&1
	touch $@

.stage.%.done: .stage.%.package .stage.%.mklittlefs .stage.%.pioasm .stage.%.openocd .stage.%.picotool
	echo STAGE: $@
	echo Done building $(call arch,$@)

# Only the native version has to be done to install libs to GIT
install: .stage.LINUX.install
.stage.LINUX.install:
	echo STAGE: $@
	rm -rf $(ARDUINO)
	git clone https://github.com/$(GHUSER)/arduino-pico $(ARDUINO)
	(cd $(ARDUINO) && git checkout $(INSTALLBRANCH) && git submodule init && git submodule update)
	echo "-------- Updating package.json"
	ver=$(REL)-$(shell git rev-parse --short HEAD); pkgfile=$(ARDUINO)/package/package_pico_index.template.json; \
	./patch_json.py --pkgfile "$${pkgfile}" --tool pqt-gcc --ver "$${ver}" --glob '*arm-none-eabi*.json' ; \
	./patch_json.py --pkgfile "$${pkgfile}" --tool pqt-gcc-riscv --ver "$${ver}" --glob '*riscv32-unknown-elf*.json' ; \
	./patch_json.py --pkgfile "$${pkgfile}" --tool pqt-pioasm --ver "$${ver}" --glob '*pioasm*json' ; \
	./patch_json.py --pkgfile "$${pkgfile}" --tool pqt-picotool --ver "$${ver}" --glob '*picotool*json' ; \
	./patch_json.py --pkgfile "$${pkgfile}" --tool pqt-mklittlefs --ver "$${ver}" --glob '*mklittlefs*json' ; \
	./patch_json.py --pkgfile "$${pkgfile}" --tool pqt-openocd --ver "$${ver}" --glob '*openocd*json' ; \
	echo "Install done"

# Upload a draft toolchain release
upload: .stage.LINUX.upload
.stage.LINUX.upload:
	echo STAGE: $@
	rm -rf ./venv
	python3 -m venv ./venv
	cd ./venv; . bin/activate; \
	    pip3 install -q pygithub ; \
	    python3 ../upload_release.py --user "$(GHUSER)" --token "$(GHTOKEN)" --tag $(REL) --msg 'See https://github.com/earlephilhower/arduino-pico for more info'  --name "Raspberry Pi Pico Quick Toolchain for $(REL)" `find ../ -maxdepth 1 -name "*.tar.gz" -o -name "*.zip"` `find ../blobs -maxdepth 1 -name "*.tar.gz" -o -name "*.zip"`
	rm -rf ./venv

# Platform.IO publish the package
publish: .stage.LINUX.publish
.stage.LINUX.publish:
	echo STAGE: $@
	find ./ -maxdepth 1 -name "*.tar.gz" -exec $(PLATFORMIO) package publish --non-interactive \{\} \;
	find ./ -maxdepth 1 -name "*.zip" -exec $(PLATFORMIO) package publish --non-interactive \{\} \;

dumpvars:
	echo SETENV:    '$(call setenvtgtcross,.stage.LINUX.stage)'
	echo CONFIGURE: '$(call configure,.stage.LINUX.stage)'
