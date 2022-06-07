
.SILENT:

# General rule is that CAPITAL variables are constants and can be used
# via $(VARNAME), while lowercase variables are dynamic and need to be
# used via $(call varname,$@) (note no space between comma and $@)

REL     := $(if $(REL),$(REL),1.0.0)
SUBREL  := $(if $(SUBREL),$(SUBREL),testing)
ARDUINO := $(if $(ARDUINO),$(ARDUINO),$(shell pwd)/arduino)
GCC     := $(if $(GCC),$(GCC),10.3)

# General constants
PWD      := $(shell pwd)
REPODIR  := $(PWD)/repo
PATCHDIR := $(PWD)/patches
STAMP    := $(shell date +%y%m%d)
ARCH     := arm-none-eabi

# For uploading, the GH user and PAT
GHUSER := $(if $(GHUSER),$(GHUSER),$(shell cat .ghuser))
GHTOKEN := $(if $(GHTOKEN),$(GHTOKEN),$(shell cat .ghtoken))
ifeq ($(GHUSER),)
    $(error Need to specify GH username on the command line "GHUSER=xxxx" or in .ghuser)
else ifeq ($(GHTOKEN),)
    $(error Need to specify GH PAT on the command line "GHTOKEN=xxxx" or in .ghtoken)
endif

NEWLIB_DIR    := newlib
NEWLIB_REPO   := git://sourceware.org/git/newlib-cygwin.git
NEWLIB_BRANCH := newlib-4.0.0

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
else ifeq ($(GCC), 12.1)
    ISL           := 0.18
    GCC_BRANCH    := releases/gcc-12.1.0
    GCC_PKGREL    := 120100
    GCC_REPO      := https://gcc.gnu.org/git/gcc.git
    GCC_DIR       := gcc-gnu
    BINUTILS_BRANCH := binutils-2_32
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

OSX_HOST   := x86_64-apple-darwin14
OSX_AHOST  := x86_64-apple-darwin
OSX_EXT    := .osx
OSX_EXE    := 
OSX_MKTGT  := osx
OSX_BFLGS  :=
OSX_TARCMD := tar
OSX_TAROPT := zcf
OSX_TAREXT := tar.gz
OSX_ASYS   := darwin_x86_64

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

RPI_HOST   := arm-linux-gnueabihf
RPI_AHOST  := arm-linux-gnueabihf
RPI_EXT    := .rpi
RPI_EXE    := 
RPI_MKTGT  := linux
RPI_BFLGS  := LDFLAGS=-static
RPI_TARCMD := tar
RPI_TAROPT := zcf
RPI_TAREXT := tar.gz
RPI_ASYS   := linux_armv6l
RPI_DEB    := armhf

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
log    = log$(1)

# For package.json
asys   = $($(call arch,$(1))_ASYS)

# The build directory per architecture
arena = $(PWD)/arena$(call ext,$(1))
# The architecture for this recipe
arch = $(subst .,,$(suffix $(basename $(1))))
# This installation directory for this architecture
install = $(PWD)/$(ARCH)$($(call arch,$(1))_EXT)

# Binary stuff we need to access
BLOBS = $(PWD)/blobs

# GCC et. al configure options
configure  = --prefix=$(call install,$(1))
configure += --build=$(shell gcc -dumpmachine)
configure += --host=$(call host,$(1))
configure += --target=$(ARCH)
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
configure += --enable-lto
configure += --enable-static=yes
configure += --disable-libstdcxx-verbose
configure += --disable-decimal-float
configure += --with-cpu=cortex-m0plus
configure += --with-no-thumb-interwork

# Newlib configuration common
CONFIGURENEWLIBCOM  = --with-newlib
CONFIGURENEWLIBCOM += --disable-newlib-io-c99-formats
CONFIGURENEWLIBCOM += --disable-newlib-supplied-syscalls
CONFIGURENEWLIBCOM += --enable-newlib-nano-formatted-io
CONFIGURENEWLIBCOM += --enable-newlib-reent-small
CONFIGURENEWLIBCOM += --enable-target-optspace
CONFIGURENEWLIBCOM += --disable-option-checking
CONFIGURENEWLIBCOM += --target=$(ARCH)
CONFIGURENEWLIBCOM += --disable-shared
CONFIGURENEWLIBCOM += --with-cpu=cortex-m0plus
CONFIGURENEWLIBCOM += --with-no-thumb-interwork

# Configuration for newlib normal build
configurenewlib  = --prefix=$(call install,$(1))
configurenewlib += $(CONFIGURENEWLIBCOM)

# Configuration for newlib install-to-arduino target
CONFIGURENEWLIBINSTALL  = --prefix=$(ARDUINO)/tools/sdk/libc
CONFIGURENEWLIBINSTALL += --with-target-subdir=$(ARCH)
CONFIGURENEWLIBINSTALL += $(CONFIGURENEWLIBCOM)

# OpenOCD configuration
CONFIGOPENOCD  = --enable-picoprobe
CONFIGOPENOCD += --enable-cmsis-dap
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
CONFIGOPENOCD += --disable-cmsis-dap-v2
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
CONFIGOPENOCD += --disable-bcm2835gpio
CONFIGOPENOCD += --disable-imx_gpio
CONFIGOPENOCD += --disable-ep93xx
CONFIGOPENOCD += --disable-at91rm9200
CONFIGOPENOCD += --disable-gw16012
CONFIGOPENOCD += --disable-oocd_trace
CONFIGOPENOCD += --disable-buspirate
CONFIGOPENOCD += --disable-sysfsgpio
CONFIGOPENOCD += --disable-xlnx-pcie-xvc
CONFIGOPENOCD += --disable-minidriver-dummy
CONFIGOPENOCD += --disable-remote-bitbang

# The branch in which to store the new toolchain
INSTALLBRANCH ?= master

# Environment variables for configure and building targets.  Only use $(call setenv,$@)
CFFT := "-Os -g -free -fipa-pta"

# Sets the environment variables for a subshell while building
setenv = export CFLAGS_FOR_TARGET=$(CFFT); \
         export CXXFLAGS_FOR_TARGET=$(CFFT); \
         export CFLAGS="-I$(call install,$(1))/include -I$(call arena,$(1))/cross/include -pipe"; \
         export LDFLAGS="-L$(call install,$(1))/lib -L$(call arena,$(1))/cross/lib"; \
         export PATH="$(call install,.stage.LINUX.stage)/bin:$${PATH}"; \
         export LD_LIBRARY_PATH="$(call install,.stage.LINUX.stage)/lib:$${LD_LIBRARY_PATH}"

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
	     echo ' "url": "https://github.com/$(GHUSER)/pico-quick-toolchain/releases/download/'$(REL)-$(SUBREL)'/'$${tarball}'",' && \
	     echo ' "archiveFileName": "'$${tarball}'",' && \
	     echo ' "checksum": "SHA-256:'$${tarballsha256}'",' && \
	     echo ' "size": "'$${tarballsize}'"' && \
	     echo '}') > $${tarball}.json

# The recpies begin here.

linux default: .stage.LINUX.done

.PRECIOUS: .stage.% .stage.%.%

.PHONY: .stage.download

# Build all toolchain versions
all: .stage.LINUX.done .stage.LINUX32.done .stage.WIN32.done .stage.WIN64.done .stage.OSX.done .stage.ARM64.done .stage.RPI.done
	echo STAGE: $@
	echo All complete

download: .stage.download

pioasm: .stage.LINUX32.pioasm .stage.WIN32.pioasm .stage.WIN64.pioasm .stage.OSX.pioasm .stage.ARM64.pioasm .stage.RPI.pioasm .stage.LINUX.pioasm

mklittlefs: .stage.LINUX32.mklittlefs .stage.WIN32.mklittlefs .stage.WIN64.mklittlefs .stage.OSX.mklittlefs .stage.ARM64.mklittlefs .stage.RPI.mklittlefs .stage.LINUX.mklittlefs

elf2uf2: .stage.LINUX32.elf2uf2 .stage.WIN32.elf2uf2 .stage.WIN64.elf2uf2 .stage.OSX.elf2uf2 .stage.ARM64.elf2uf2 .stage.RPI.elf2uf2 .stage.LINUX.elf2uf2

openocd: .stage.LINUX32.openocd .stage.WIN32.openocd .stage.WIN64.openocd .stage.OSX.openocd .stage.ARM64.openocd .stage.RPI.openocd .stage.LINUX.openocd

# Other cross-compile cannot start until Linux is built
.stage.LINUX32.gcc1-make .stage.WIN32.gcc1-make .stage.WIN64.gcc1-make .stage.OSX.gcc1-make .stage.ARM64.gcc1-make .stage.RPI.gcc1-make: .stage.LINUX.done


# Clean all temporary outputs
clean: .cleaninst.LINUX.clean .cleaninst.LINUX32.clean .cleaninst.WIN32.clean .cleaninst.WIN64.clean .cleaninst.OSX.clean .cleaninst.ARM64.clean .cleaninst.RPI.clean
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
	(test -d $(REPODIR)/openocd         || git clone https://github.com/$(GHUSER)/openocd.git       $(REPODIR)/openocd     ) >> $(call log,$@) 2>&1
	(test -d $(REPODIR)/libexpat        || git clone https://github.com/libexpat/libexpat.git       $(REPODIR)/libexpat    ) >> $(call log,$@) 2>&1
	touch $@

# Completely clean out a git directory, removing any untracked files
.clean.%.git:
	echo STAGE: $@
	(cd $(REPODIR)/$(call arch,$@) && git reset --hard HEAD && git clean -f -d) > $(call log,$@) 2>&1

.clean.gits: .clean.$(BINUTILS_DIR).git .clean.$(GCC_DIR).git .clean.newlib.git .clean.newlib.git .clean.mklittlefs.git .clean.pico-sdk.git .clean.openocd.git

# Prep the git repos with no patches and any required libraries for gcc
.stage.prepgit: .stage.download .clean.gits
	echo STAGE: $@
	for i in $(BINUTILS_DIR) $(GCC_DIR) newlib mklittlefs pico-sdk openocd libexpat; do \
            cd $(REPODIR)/$$i && git reset --hard HEAD && git submodule init && git submodule update && git clean -f -d; \
        done > $(call log,$@) 2>&1
	for url in $(GNUHTTP)/gmp-6.1.0.tar.bz2 $(GNUHTTP)/mpfr-3.1.4.tar.bz2 $(GNUHTTP)/mpc-1.0.3.tar.gz \
	           $(GNUHTTP)/isl-$(ISL).tar.bz2 $(GNUHTTP)/cloog-0.18.1.tar.gz https://github.com/earlephilhower/pico-quick-toolchain/raw/master/blobs/libelf-0.8.13.tar.gz ; do \
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
	(cd $(REPODIR)/openocd && git reset --hard && git checkout rp2040 && git submodule update --init --recursive) >> $(call log,$@) 2>&1
	(cd $(REPODIR)/libexpat && git reset --hard && git checkout R_2_4_4 && git submodule update --init --recursive) >> $(call log,$@) 2>&1
	(cd $(REPODIR)/pico-sdk && git reset --hard && git checkout $(PICOSCK_BRANCH)) >> $(call log,$@) 2>&1
	touch $@

# Apply our patches
.stage.patch: .stage.checkout
	echo STAGE: $@
	for p in $(PATCHDIR)/gcc-*.patch $(PATCHDIR)/gcc$(GCC)/gcc-*.patch; do \
	    test -r "$$p" || continue ; \
	    (cd $(REPODIR)/$(GCC_DIR); echo "---- $$p:"; patch -s -p1 < $$p) ; \
	done > $(call log,$@) 2>&1
	for p in $(PATCHDIR)/bin-*.patch; do \
	    test -r "$$p" || continue ; \
	    (cd $(REPODIR)/$(BINUTILS_DIR); echo "---- $$p:"; patch -s -p1 < $$p) ; \
	done >> $(call log,$@) 2>&1
	for p in $(PATCHDIR)/lib-*.patch; do \
	    test -r "$$p" || continue ; \
	    (cd $(REPODIR)/newlib; echo "---- $$p: "; patch -s -p1 < $$p) ; \
	done >> $(call log,$@) 2>&1
	touch $@

.stage.%.start: .stage.patch
	echo STAGE: $@
	mkdir -p $(call arena,$@) > $(call log,$@) 2>&1

# Build expat for proper GDB support
.stage.%.expat: .stage.%.start
	rm -rf $(call arena,$@)/expat $(call arena,$@)/cross > $(call log,$@) 2>&1
	cp -a $(REPODIR)/libexpat/expat $(call arena,$@)/expat >> $(call log,$@) 2>&1
	(cd $(call arena,$@)/expat && bash buildconf.sh && ./configure $(call configure,$@) --prefix=$(call arena,$@)/cross && make && make install) >> $(call log,$@) 2>&1
	touch $@

# Build binutils
.stage.%.binutils-config: .stage.%.expat
	echo STAGE: $@
	rm -rf $(call arena,$@)/$(BINUTILS_DIR) > $(call log,$@) 2>&1
	mkdir -p $(call arena,$@)/$(BINUTILS_DIR) >> $(call log,$@) 2>&1
	(cd $(call arena,$@)/$(BINUTILS_DIR); $(call setenv,$@); $(REPODIR)/$(BINUTILS_DIR)/configure $(call configure,$@)) >> $(call log,$@) 2>&1
	touch $@

.stage.%.binutils-make: .stage.%.binutils-config
	echo STAGE: $@
	# Need LDFLAGS override to guarantee gdb is made static
	(cd $(call arena,$@)/$(BINUTILS_DIR); $(call setenv,$@); export LDFLAGS="$$LDFLAGS -static"; $(MAKE)) > $(call log,$@) 2>&1
	(cd $(call arena,$@)/$(BINUTILS_DIR); $(call setenv,$@); $(MAKE) install) >> $(call log,$@) 2>&1
	(cd $(call install,$@)/bin; ln -sf $(ARCH)-gcc$(call exe,$@) $(ARCH)-cc$(call exe,$@)) >> $(call log,$@) 2>&1
	touch $@

.stage.%.gcc1-config: .stage.%.binutils-make
	echo STAGE: $@
	rm -rf $(call arena,$@)/$(GCC_DIR) > $(call log,$@) 2>&1
	mkdir -p $(call arena,$@)/$(GCC_DIR) >> $(call log,$@) 2>&1
	(cd $(call arena,$@)/$(GCC_DIR); $(call setenv,$@); $(REPODIR)/$(GCC_DIR)/configure $(call configure,$@)) >> $(call log,$@) 2>&1
	touch $@

.stage.%.gcc1-make: .stage.%.gcc1-config
	echo STAGE: $@
	(cd $(call arena,$@)/$(GCC_DIR); $(call setenv,$@); $(MAKE) all-gcc; $(MAKE) install-gcc) > $(call log,$@) 2>&1
	touch $@

.stage.%.newlib-config: .stage.%.gcc1-make
	echo STAGE: $@
	rm -rf $(call arena,$@)/newlib > $(call log,$@) 2>&1
	mkdir -p $(call arena,$@)/newlib >> $(call log,$@) 2>&1
	(cd $(call arena,$@)/newlib; $(call setenv,$@); $(REPODIR)/newlib/configure $(call configurenewlib,$@)) >> $(call log,$@) 2>&1
	touch $@

.stage.%.newlib-make: .stage.%.newlib-config
	echo STAGE: $@
	(cd $(call arena,$@)/newlib; $(call setenv,$@); $(MAKE)) > $(call log,$@) 2>&1
	(cd $(call arena,$@)/newlib; $(call setenv,$@); $(MAKE) install -j1) >> $(call log,$@) 2>&1
	touch $@

.stage.%.libstdcpp: .stage.%.newlib-make
	echo STAGE: $@
	# stage 2 (build libstdc++)
	(cd $(call arena,$@)/$(GCC_DIR); $(call setenv,$@); $(MAKE)) > $(call log,$@) 2>&1
	(cd $(call arena,$@)/$(GCC_DIR); $(call setenv,$@); $(MAKE) install) >> $(call log,$@) 2>&1
	touch $@

.stage.%.libstdcpp-nox: .stage.%.libstdcpp
	echo STAGE: $@
	# We copy existing stdc, adjust the makefile, and build a single .a to save much time
	cp $(ARCH)$(call ext,$@)/$(ARCH)/lib/thumb/libstdc++.a $(ARCH)$(call ext,$@)/$(ARCH)/lib/thumb/libstdc++-exc.a >> $(call log,$@) 2>&1
	rm -rf $(call arena,$@)/$(GCC_DIR)/$(ARCH)/libstdc++-v3-nox > $(call log,$@) 2>&1
	cp -a $(call arena,$@)/$(GCC_DIR)/$(ARCH)/libstdc++-v3 $(call arena,$@)/$(GCC_DIR)/$(ARCH)/libstdc++-v3-nox >> $(call log,$@) 2>&1
	(cd $(call arena,$@)/$(GCC_DIR)/$(ARCH)/libstdc++-v3-nox; $(call setenv,$@); $(MAKE) clean; find . -name Makefile -exec sed -i 's/-free/-free -fno-exceptions/' \{\} \; ; $(MAKE)) >> $(call log,$@) 2>&1
	cp $(call arena,$@)/$(GCC_DIR)/$(ARCH)/libstdc++-v3-nox/src/.libs/libstdc++.a $(ARCH)$(call ext,$@)/$(ARCH)/lib/thumb/libstdc++.a >> $(call log,$@) 2>&1
	touch $@

.stage.%.strip: .stage.%.libstdcpp-nox
	echo STAGE: $@
	($(call setenv,$@); $(call host,$@)-strip $(call install,$@)/bin/*$(call exe,$@) $(call install,$@)/libexec/gcc/$(ARCH)/*/c*$(call exe,$@) $(call install,$@)/libexec/gcc/$(ARCH)/*/lto1$(call exe,$@) || true ) > $(call log,$@) 2>&1
	touch $@

.stage.%.post: .stage.%.strip
	echo STAGE: $@
	for sh in post/$(GCC)*.sh; do \
	    [ -x "$${sh}" ] && $${sh} $(call ext,$@) ; \
	done > $(call log,$@) 2>&1
	touch $@

.stage.%.package: .stage.%.post
	echo STAGE: $@
	rm -rf pkg.$(call arch,$@) > $(call log,$@) 2>&1
	mkdir -p pkg.$(call arch,$@) >> $(call log,$@) 2>&1
	cp -a $(call install,$@) pkg.$(call arch,$@)/$(ARCH) >> $(call log,$@) 2>&1
	(cd pkg.$(call arch,$@)/$(ARCH); $(call setenv,$@); pkgdesc="$(ARCH)-gcc"; pkgname="toolchain-pico"; $(call makepackagejson,$@)) >> $(call log,$@) 2>&1
	(tarball=$(call host,$@).$(ARCH)-$$(git rev-parse --short HEAD).$(STAMP).$(call tarext,$@) ; \
	    cd pkg.$(call arch,$@) && $(call tarcmd,$@) $(call taropt,$@) ../$${tarball} $(ARCH)/ ; cd ..; $(call makejson,$@)) >> $(call log,$@) 2>&1
	rm -rf pkg.$(call arch,$@) >> $(call log,$@) 2>&1
	touch $@

.stage.%.mklittlefs: .stage.%.start
	echo STAGE: $@
	rm -rf $(call arena,$@)/mklittlefs > $(call log,$@) 2>&1
	cp -a $(REPODIR)/mklittlefs $(call arena,$@)/mklittlefs >> $(call log,$@) 2>&1
	# Dependencies borked in mklittlefs makefile, so don't use parallel make
	(cd $(call arena,$@)/mklittlefs;\
	    $(call setenv,$@); \
	    TARGET_OS=$(call mktgt,$@) CC=$(call host,$@)-gcc CXX=$(call host,$@)-g++ STRIP=$(call host,$@)-strip \
            make -j1 clean mklittlefs$(call exe,$@) BUILD_CONFIG_NAME="-arduino-rpipico") >> $(call log,$@) 2>&1
	rm -rf pkg.mklittlefs.$(call arch,$@) >> $(call log,$@) 2>&1
	mkdir -p pkg.mklittlefs.$(call arch,$@)/mklittlefs >> $(call log,$@) 2>&1
	(cd pkg.mklittlefs.$(call arch,$@)/mklittlefs; $(call setenv,$@); pkgdesc="littlefs-utility"; pkgname="mklittlefs"; $(call makepackagejson,$@)) >> $(call log,$@) 2>&1
	cp $(call arena,$@)/mklittlefs/mklittlefs$(call exe,$@) pkg.mklittlefs.$(call arch,$@)/mklittlefs/. >> $(call log,$@) 2>&1
	(tarball=$(call host,$@).mklittlefs-$$(cd $(REPODIR)/mklittlefs && git rev-parse --short HEAD).$(STAMP).$(call tarext,$@) ; \
	    cd pkg.mklittlefs.$(call arch,$@) && $(call tarcmd,$@) $(call taropt,$@) ../$${tarball} mklittlefs; cd ..; $(call makejson,$@)) >> $(call log,$@) 2>&1
	rm -rf pkg.mklittlefs.$(call arch,$@) >> $(call log,$@) 2>&1
	touch $@

.stage.%.elf2uf2: .stage.%.start
	echo STAGE: $@
	rm -rf $(call arena,$@)/elf2uf2 > $(call log,$@) 2>&1
	mkdir $(call arena,$@)/elf2uf2 >> $(call log,$@) 2>&1
	(cd $(REPODIR)/pico-sdk/tools/elf2uf2; $(call host,$@)-g++ -std=gnu++11 -o $(call arena,$@)/elf2uf2/elf2uf2$(call exe,$@) -I../../src/common/boot_uf2/include main.cpp -static-libgcc -static-libstdc++) >> $(call log,$@) 2>&1
	rm -rf pkg.elf2uf2.$(call arch,$@) >> $(call log,$@) 2>&1
	mkdir -p pkg.elf2uf2.$(call arch,$@)/elf2uf2 >> $(call log,$@) 2>&1
	(cd pkg.elf2uf2.$(call arch,$@)/elf2uf2; $(call setenv,$@); pkgdesc="elf2uf2-utility"; pkgname="elf2uf2"; $(call makepackagejson,$@)) >> $(call log,$@) 2>&1
	$(call host,$@)-strip $(call arena,$@)/elf2uf2/elf2uf2$(call exe,$@) >> $(call log,$@) 2>&1
	cp $(call arena,$@)/elf2uf2/elf2uf2$(call exe,$@) pkg.elf2uf2.$(call arch,$@)/elf2uf2/. >> $(call log,$@) 2>&1
	(tarball=$(call host,$@).elf2uf2-$$(cd $(REPODIR)/pico-sdk && git rev-parse --short HEAD).$(STAMP).$(call tarext,$@) ; \
	    cd pkg.elf2uf2.$(call arch,$@) && $(call tarcmd,$@) $(call taropt,$@) ../$${tarball} elf2uf2; cd ..; $(call makejson,$@)) >> $(call log,$@) 2>&1
	rm -rf pkg.elf2uf2.$(call arch,$@) >> $(call log,$@) 2>&1
	touch $@

.stage.%.pioasm: .stage.%.start
	echo STAGE: $@
	rm -rf $(call arena,$@)/pioasm > $(call log,$@) 2>&1
	mkdir $(call arena,$@)/pioasm >> $(call log,$@) 2>&1
	(cd $(REPODIR)/pico-sdk/tools/pioasm; $(call host,$@)-g++ -std=gnu++11 -o $(call arena,$@)/pioasm/pioasm$(call exe,$@) main.cpp pio_assembler.cpp pio_disassembler.cpp gen/lexer.cpp gen/parser.cpp c_sdk_output.cpp python_output.cpp hex_output.cpp -Igen/ -I. -static-libgcc -static-libstdc++) >> $(call log,$@) 2>&1
	rm -rf pkg.pioasm.$(call arch,$@) >> $(call log,$@) 2>&1
	mkdir -p pkg.pioasm.$(call arch,$@)/pioasm >> $(call log,$@) 2>&1
	(cd pkg.pioasm.$(call arch,$@)/pioasm; $(call setenv,$@); pkgdesc="pioasm-utility"; pkgname="pioasm"; $(call makepackagejson,$@)) >> $(call log,$@) 2>&1
	$(call host,$@)-strip $(call arena,$@)/pioasm/pioasm$(call exe,$@) >> $(call log,$@) 2>&1
	cp $(call arena,$@)/pioasm/pioasm$(call exe,$@) pkg.pioasm.$(call arch,$@)/pioasm/. >> $(call log,$@) 2>&1
	(tarball=$(call host,$@).pioasm-$$(cd $(REPODIR)/pico-sdk && git rev-parse --short HEAD).$(STAMP).$(call tarext,$@) ; \
	    cd pkg.pioasm.$(call arch,$@) && $(call tarcmd,$@) $(call taropt,$@) ../$${tarball} pioasm; cd ..; $(call makejson,$@)) >> $(call log,$@) 2>&1
	rm -rf pkg.pioasm.$(call arch,$@) >> $(call log,$@) 2>&1
	touch $@

.stage.ARM64.openocd-prep: .stage.ARM64.start
	echo STAGE: $@
	rm -rf $(call arena,$@)/openocd > $(call log,$@) 2>&1
	cp -a $(REPODIR)/openocd $(call arena,$@)/openocd >> $(call log,$@) 2>&1
	(cd $(call arena,$@); for i in $(BLOBS)/*_$(call deb, $@).deb; do ar x $$i; tar xvf data.tar.xz; done) >> $(call log,$@) 2>&1
	(for i in $(call arena,$@)/usr/lib/$(call host,$@)/pkgconfig/*.pc; do sed -i 's@^prefix=.*@prefix=$(call arena,$@)/usr@' $$i; done) >> $(call log,$@) 2>&1
	(echo cp $(call arena,$@)/lib/$(call host,$@)/* $(call arena,$@)/usr/lib/$(call host,$@)/.) >> $(call log,$@) 2>&1
	(cp $(call arena,$@)/lib/$(call host,$@)/* $(call arena,$@)/usr/lib/$(call host,$@)/.) >> $(call log,$@) 2>&1
	(cd $(call arena,$@)/openocd; PKG_CONFIG_PATH=$(call arena,$@)/usr/lib/$(call host,$@)/pkgconfig LIBS="-ludev -lpthread" LDFLAGS=-L$(call arena,$@)/lib/$(call host,$@) \
         ./configure $(CONFIGOPENOCD) --prefix $(call arena,$@)/pkg.openocd.$(call arch,$@)/openocd --host=$(call host,$@)) >> $(call log,$@) 2>&1

.stage.RPI.openocd-prep: .stage.RPI.start
	echo STAGE: $@
	rm -rf $(call arena,$@)/openocd > $(call log,$@) 2>&1
	cp -a $(REPODIR)/openocd $(call arena,$@)/openocd >> $(call log,$@) 2>&1
	(cd $(call arena,$@); for i in $(BLOBS)/*_$(call deb, $@).deb; do ar x $$i; tar xvf data.tar.xz; done) >> $(call log,$@) 2>&1
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
.stage.OSX.openocd: .stage.OSX.start
.stage.WIN32.openocd .stage.WIN64.openocd .stage.OSX.openocd:
	echo STAGE: $@
	rm -rf $(call arena,$@)/openocd > $(call log,$@) 2>&1
	mkdir -p pkg.openocd.$(call arch,$@) >> $(call log,$@) 2>&1
	(cd pkg.openocd.$(call arch,$@); tar xf $(BLOBS)/openocd$(call ext,$@).tar.gz) >> $(call log,$@) 2>&1
	(cd pkg.openocd.$(call arch,$@)/openocd; $(call setenv,$@); pkgdesc="openocd-utility"; pkgname="openocd"; $(call makepackagejson,$@)) >> $(call log,$@) 2>&1
	(tarball=$(call host,$@).openocd-$$(cd $(REPODIR)/openocd && git rev-parse --short HEAD).$(STAMP).$(call tarext,$@) ; \
	    cd pkg.openocd.$(call arch,$@) && $(call tarcmd,$@) $(call taropt,$@) ../$${tarball} openocd; cd ..; $(call makejson,$@)) >> $(call log,$@) 2>&1
	rm -rf pkg.openocd.$(call arch,$@) >> $(call log,$@) 2>&1
	touch $@

.stage.%.openocd: .stage.%.openocd-prep
	echo STAGE: $@
	(cd $(call arena,$@)/openocd && make -j4 && make install) >> $(call log,$@) 2>&1
	(cd $(call arena,$@)/pkg.openocd.$(call arch,$@)/openocd; $(call setenv,$@); pkgdesc="openocd-utility"; pkgname="openocd"; $(call makepackagejson,$@)) >> $(call log,$@) 2>&1
	(tarball=$(call host,$@).openocd-$$(cd $(REPODIR)/openocd && git rev-parse --short HEAD).$(STAMP).$(call tarext,$@) ; \
	    cd $(call arena,$@)/pkg.openocd.$(call arch,$@) && $(call tarcmd,$@) $(call taropt,$@) ../../$${tarball} openocd; cd ../..; $(call makejson,$@)) >> $(call log,$@) 2>&1
	rm -rf $(call arena,$@)/pkg.openocd.$(call arch,$@) >> $(call log,$@) 2>&1
	touch $@

.stage.%.done: .stage.%.package .stage.%.mklittlefs .stage.%.elf2uf2 .stage.%.pioasm .stage.%.openocd
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
	ver=$(REL)-$(SUBREL)-$(shell git rev-parse --short HEAD); pkgfile=$(ARDUINO)/package/package_pico_index.template.json; \
	./patch_json.py --pkgfile "$${pkgfile}" --tool pqt-gcc --ver "$${ver}" --glob '*$(ARCH)*.json' ; \
	./patch_json.py --pkgfile "$${pkgfile}" --tool pqt-elf2uf2 --ver "$${ver}" --glob '*elf2uf2*json' ; \
	./patch_json.py --pkgfile "$${pkgfile}" --tool pqt-pioasm --ver "$${ver}" --glob '*pioasm*json' ; \
	./patch_json.py --pkgfile "$${pkgfile}" --tool pqt-mklittlefs --ver "$${ver}" --glob '*mklittlefs*json' ; \
	./patch_json.py --pkgfile "$${pkgfile}" --tool pqt-openocd --ver "$${ver}" --glob '*openocd*json' ; \
	echo "Install done"

# Upload a draft toolchain release
upload: .stage.LINUX.upload
.stage.LINUX.upload:
	echo STAGE: $@
	cp -f blobs/* .
	rm -rf ./venv
	python3 -m venv ./venv
	cd ./venv; . bin/activate; \
	    pip3 install -q pygithub ; \
	    python3 ../upload_release.py --user "$(GHUSER)" --token "$(GHTOKEN)" --tag $(REL)-$(SUBREL) --msg 'See https://github.com/earlephilhower/ArduinoPico for more info'  --name "Raspberry Pi Pico Quick Toolchain for $(REL)-$(SUBREL)" `find ../ -maxdepth 1 -name "*.tar.gz" -o -name "*.zip"` ;
	rm -rf ./venv

dumpvars:
	echo SETENV:    '$(call setenv,.stage.LINUX.stage)'
	echo CONFIGURE: '$(call configure,.stage.LINUX.stage)'
	echo NEWLIBCFG: '$(call configurenewlib,.stage.LINUX.stage)'
