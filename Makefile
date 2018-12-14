

# General rule is that CAPITAL variables are constants and can be used
# via $(VARNAME), while lowercase variables are dynamic and need to be
# used via $(call varname,$@) (note no space between comma and $@)

REL     := $(if $(REL),$(REL),2.5.0)
SUBREL  := $(if $(SUBREL),$(SUBREL),testing)
ARDUINO := $(if $(ARDUINO),$(ARDUINO),$(shell pwd)/arduino)
GCC     := $(if $(GCC),$(GCC),4.8)

# General constants
PWD      := $(shell pwd)
REPODIR  := $(PWD)/repo
PATCHDIR := $(PWD)/patches

# For uploading, the GH user and password
GHUSER := $(if $(GHUSER),$(GHUSER),$(shell cat .ghuser))
GHPASS := $(if $(GHPASS),$(GHPASS),$(shell cat .ghpass))
ifeq ($(GHUSER),)
    $(error Need to specify GH username on the command line "GHUSER=xxxx" or in .ghuser)
else ifeq ($(GHPASS),)
    $(error Need to specify GH password on the command line "GHPASS=xxxx" or in .gphass)
endif

# Depending on the GCC version get proper branch and support libs
ifeq ($(GCC),4.8)
    ISL        := 0.12.2
    GCC_BRANCH := call0-4.8.2
else ifeq ($(GCC),4.9)
    ISL        := 0.12.2
    GCC_BRANCH := call0-4.9.2
else ifeq ($(GCC),5.2)
    ISL        := 0.12.2
    GCC_BRANCH := xtensa-ctng-esp-5.2.0
else ifeq ($(GCC),7.2)
    ISL        := 0.16.1
    GCC_BRANCH := xtensa-ctng-7.2.0
else
    $(error Need to specify a supported GCC version "GCC={4.8, 4.9, 5.2, 7.2}")
endif

# MKSPIFFS must stay at 0.2.0 until Arduino boards.txt.py fixes non-page-aligned sizes
MKSPIFFS_BRANCH := 0.2.0

# LTO doesn't work on 4.8, may not be useful later
LTO := $(if $(lto),$(lto),false)

# Define the build and output naming, don't use directly (see below)
LINUX_HOST  := x86_64-linux-gnu
LINUX_AHOST := x86_64-pc-linux-gnu
LINUX_EXT   := .x86_64
LINUX_EXE   := 
LINUX_MKTGT := linux

WIN32_HOST  := i686-w64-mingw32
WIN32_AHOST := i686-mingw32
WIN32_EXT   := .win32
WIN32_EXE   := .exe
WIN32_MKTGT := windows

WIN64_HOST  := x86_64-w64-mingw32
WIN64_AHOST := x86_64-mingw32
WIN64_EXT   := .win64
WIN64_EXE   := .exe
WIN64_MKTGT := windows

OSX_HOST  := x86_64-apple-darwin14
OSX_AHOST := x86_64-apple-darwin
OSX_EXT   := .osx
OSX_EXE   := 
OSX_MKTGT := osx

ARM64_HOST  := aarch64-linux-gnu
ARM64_AHOST := aarch64-linux-gnu
ARM64_EXT   := .arm64
ARM64_EXE   := 
ARM64_MKTGT := linux

RPI_HOST  := arm-linux-gnueabihf
RPI_AHOST := arm-linux-gnueabihf
RPI_EXT   := .rpi
RPI_EXE   := 
RPI_MKTGT := linux

# Call with $@ to get the appropriate variable for this architecture
host  = $($(call arch,$(1))_HOST)
ahost = $($(call arch,$(1))_AHOST)
ext   = $($(call arch,$(1))_EXT)
exe   = $($(call arch,$(1))_EXE)
mktgt = $($(call arch,$(1))_MKTGT)

# The build directory per architecture
arena = $(PWD)/arena$(call ext,$(1))
# The architecture for this recipe
arch = $(subst .,,$(suffix $(basename $(1))))
# This installation directory for this architecture
install = $(PWD)/xtensa-lx106-elf$($(call arch,$(1))_EXT)

# GCC et. al configure options
configure  = --prefix=$(call install,$(1))
configure += --build=$(shell gcc -dumpmachine)
configure += --host=$(call host,$(1))
configure += --target=xtensa-lx106-elf
configure += --disable-shared
configure += --with-newlib
configure += --enable-threads=no
configure += --disable-__cxa_atexit
configure += --disable-libgomp
configure += --disable-libmudflap
configure += --disable-nls
configure += --disable-multilib
configure += --disable-bootstrap
configure += --enable-languages=c,c++
configure += --enable-lto
configure += --enable-static=yes
configure += --disable-libstdcxx-verbose

# Newlib configuration common
CONFIGURENEWLIBCOM  = --with-newlib
CONFIGURENEWLIBCOM += --enable-multilib
CONFIGURENEWLIBCOM += --disable-newlib-io-c99-formats
CONFIGURENEWLIBCOM += --disable-newlib-supplied-syscalls
CONFIGURENEWLIBCOM += --enable-newlib-nano-formatted-io
CONFIGURENEWLIBCOM += --enable-newlib-reent-small
CONFIGURENEWLIBCOM += --enable-target-optspace
CONFIGURENEWLIBCOM += --disable-option-checking
CONFIGURENEWLIBCOM += --target=xtensa-lx106-elf
CONFIGURENEWLIBCOM += --disable-shared

# Configuration for newlib normal build
configurenewlib  = --prefix=$(call install,$(1))
configurenewlib += $(CONFIGURENEWLIBCOM)

# Configuration for newlib install-to-arduino target
CONFIGURENEWLIBINSTALL  = --prefix=$(ARDUINO)/tools/sdk/libc
CONFIGURENEWLIBINSTALL += --with-target-subdir=xtensa-lx106-elf
CONFIGURENEWLIBINSTALL += $(CONFIGURENEWLIBCOM)

# Commands to make a compressed release artifact
tarcmd = $(if ifeq(windows,$(call mktgt,$(1))),tar,zip)
taropt = $(if ifeq(windows,$(call mktgt,$(1))),zcf,-rq)
tarext = $(if ifeq(windows,$(call mktgt,$(1))),tar.gz,zip)

# Environment variables for configure and building targets.  Only use $(call setenv,$@)
ifeq ($(LTO),true)
    CFFT := "-mlongcalls -flto -Wl,-flto -Os -g"
else ifeq ($(LTO),false)
    CFFT := "-mlongcalls -Os -g"
else
    $(error Need to specify LTO={true,false} on the command line)
endif
# Sets the environment variables for a subshell while building
setenv = export CFLAGS_FOR_TARGET=$(CFFT); \
         export CXXFLAGS_FOR_TARGET=$(CFFT); \
         export CFLAGS="-I$(call install,$(1))/include -pipe"; \
         export LDFLAGS="-L$(call install,$(1))/lib"; \
         export PATH="$(call install,.stage.LINUX.stage)/bin:$${PATH}"; \
         export LD_LIBRARY_PATH="$(call install,.stage.LINUX.stage)/lib:$${LD_LIBRARY_PATH}"

# Generates a JSON fragment for an uploaded release artifact
makejson = tarballsize=$$(stat -c%s $${tarball}); \
	   tarballsha256=$$(sha256sum $${tarball} | cut -f1 -d" "); \
	   ( echo '{' && \
	     echo ' "host": "'$(call ahost,$(1))'",' && \
	     echo ' "url": "https://github.com/$(GHUSER)/esp-quick-toolchain/releases/download/'$(REL)-$(SUBREL)'/'$${tarball}'",' && \
	     echo ' "archiveFileName": "'$${tarball}'",' && \
	     echo ' "checksum": "SHA-256:'$${tarballsha256}'",' && \
	     echo ' "size": "'$${tarballsize}'"' && \
	     echo '}') > $${tarball}.json

# The recpies begin here.

# Build all toolchain versions
all: .stage.LINUX.done .stage.WIN32.done .stage.WIN64.done .stage.OSX.done .stage.ARM64.done .stage.RPI.done
	echo All complete

# Other cross-compile cannot start until Linux is built
.stage.WIN32.start .stage.WIN64.start .stage.OSX.start .stage.ARM64.start .stage.RPI.start: .stage.LINUX.done


# Clean all temporary outputs
clean: .cleaninst.LINUX.clean .cleaninst.WIN32.clean .cleaninst.WIN64.clean .cleaninst.OSX.clean .cleaninst.ARM64.clean .cleaninst.RPI.clean
	rm -rf .stage* *.json *.tar.gz *.zip venv $(ARDUINO) pkg.*

# Clean an individual architecture and arena dir
.cleaninst.%.clean:
	rm -rf $(call install,$@)
	rm -rf $(call arena,$@)

# Download the needed GIT and tarballs
GNUHTTP := https://gcc.gnu.org/pub/gcc/infrastructure
.stage.download:
	mkdir -p $(REPODIR)
	test -d $(REPODIR)/binutils-gdb || git clone https://github.com/$(GHUSER)/binutils-gdb-xtensa.git $(REPODIR)/binutils-gdb
	test -d $(REPODIR)/gcc          || git clone https://github.com/$(GHUSER)/gcc-xtensa.git          $(REPODIR)/gcc
	test -d $(REPODIR)/newlib       || git clone https://github.com/$(GHUSER)/newlib-xtensa.git       $(REPODIR)/newlib
	test -d $(REPODIR)/lx106-hal    || git clone https://github.com/$(GHUSER)/lx106-hal.git           $(REPODIR)/lx106-hal
	test -d $(REPODIR)/mkspiffs     || git clone https://github.com/$(GHUSER)/mkspiffs.git            $(REPODIR)/mkspiffs
	test -d $(REPODIR)/esptool      || git clone https://github.com/$(GHUSER)/esptool-ck.git          $(REPODIR)/esptool
	touch $@

# Completely clean out a git directory, removing any untracked files
.clean.%.git:
	cd $(REPODIR)/$(call arch,$@) && git reset --hard HEAD && git clean -f -d

.clean.gits: .clean.binutils-gdb.git .clean.gcc.git .clean.newlib.git .clean.newlib.git .clean.lx106-hal.git .clean.mkspiffs.git .clean.esptool.git

# Prep the git repos with no patches and any required libraries for gcc
.stage.prepgit: .stage.download .clean.gits
	for url in $(GNUHTTP)/gmp-6.1.0.tar.bz2 $(GNUHTTP)/mpfr-3.1.4.tar.bz2 $(GNUHTTP)/mpc-1.0.3.tar.gz \
	           $(GNUHTTP)/isl-$(ISL).tar.bz2 $(GNUHTTP)/cloog-0.18.1.tar.gz http://www.mr511.de/software/libelf-0.8.13.tar.gz ; do \
	    archive=$${url##*/}; name=$${archive%.t*}; base=$${name%-*}; ext=$${archive##*.} ; \
	    echo "-------- getting $${name}" ; \
	    cd $(REPODIR) && ( test -r $${archive} || wget $${url} ) ; \
	    case "$${ext}" in \
	        gz)  (cd $(REPODIR)/gcc; tar xfz ../$${archive});; \
	        bz2) (cd $(REPODIR)/gcc; tar xfj ../$${archive});; \
	    esac ; \
	    (cd $(REPODIR)/gcc; rm -f $${base}; ln -s $${name} $${base}) \
	done
	touch $@

# Checkout any required branches
.stage.checkout: .stage.prepgit
	cd $(REPODIR)/gcc && git reset --hard && git checkout $(GCC_BRANCH)
	cd $(REPODIR)/mkspiffs && git reset --hard && git checkout $(MKSPIFFS_BRANCH) && git submodule update
	touch $@

# Apply our patches
.stage.patch: .stage.checkout
	echo "Patching source files"
	for p in $(PATCHDIR)/gcc-*.patch $(PATCHDIR)/gcc$(GCC)/gcc-*.patch; do \
	    test -r "$$p" || continue ; \
	    (cd $(REPODIR)/gcc; echo "---- $$p:"; patch -s -p1 < $$p) ; \
	done
	for p in $(PATCHDIR)/bin-*.patch; do \
	    test -r "$$p" || continue ; \
	    (cd $(REPODIR)/binutils-gdb; echo "---- $$p:"; patch -s -p1 < $$p) ; \
	done
	for p in $(PATCHDIR)/lib-*.patch; do \
	    test -r "$$p" || continue ; \
	    (cd $(REPODIR)/newlib; echo "---- $$p: "; patch -s -p1 < $$p) ; \
	done
	for p in $(PATCHDIR)/mkspiffs/$(MKSPIFFS_BRANCH)*.patch; do \
	    test -r "$$p" || continue ; \
	    (cd $(REPODIR)/mkspiffs; echo "---- $$p: "; patch -s -p1 < $$p) ; \
	done
	# Dirty-force HAL definition to binutils and gcc
	for ow in $(REPODIR)/gcc/include/xtensa-config.h $(REPODIR)/binutils-gdb/include/xtensa-config.h; do \
	    ( cat $(REPODIR)/lx106-hal/include/xtensa/config/core-isa.h; \
	      cat $(REPODIR)/lx106-hal/include/xtensa/config/system.h ; \
	      echo '#define XCHAL_HAVE_FP_DIV   0' ; \
              echo '#define XCHAL_HAVE_FP_RECIP 0' ; \
              echo '#define XCHAL_HAVE_FP_SQRT  0' ; \
              echo '#define XCHAL_HAVE_FP_RSQRT 0' ) > $${ow} ; \
        done
	cd $(REPODIR)/lx106-hal && autoreconf -i
	touch $@

.stage.%.start: .stage.patch
	echo "Beginning $(call arch,$@) build"
	mkdir -p $(call arena,$@)

# Build binutils
.stage.%.binutils-config: .stage.%.start
	rm -rf $(call arena,$@)/binutils-gdb
	mkdir -p $(call arena,$@)/binutils-gdb
	cd $(call arena,$@)/binutils-gdb; $(call setenv,$@); $(REPODIR)/binutils-gdb/configure $(call configure,$@)
	touch $@

.stage.%.binutils-make: .stage.%.binutils-config
	cd $(call arena,$@)/binutils-gdb; $(call setenv,$@); $(MAKE) LDFLAGS=-static
	cd $(call arena,$@)/binutils-gdb; $(call setenv,$@); $(MAKE) install
	cd $(call install,$@)/bin; ln -sf xtensa-lx106-elf-gcc$(call exe,$@) xtensa-lx106-elf-cc$(call exe,$@)
	touch $@

.stage.%.gcc1-config: .stage.%.binutils-make
	rm -rf $(call arena,$@)/gcc
	mkdir -p $(call arena,$@)/gcc
	cd $(call arena,$@)/gcc; $(call setenv,$@); $(REPODIR)/gcc/configure $(call configure,$@)
	touch $@

.stage.%.gcc1-make: .stage.%.gcc1-config
	cd $(call arena,$@)/gcc; $(call setenv,$@); $(MAKE) all-gcc; $(MAKE) install-gcc
	touch $@

.stage.%.newlib-config: .stage.%.gcc1-make
	rm -rf $(call arena,$@)/newlib
	mkdir -p $(call arena,$@)/newlib
	cd $(call arena,$@)/newlib; $(call setenv,$@); $(REPODIR)/newlib/configure $(call configurenewlib,$@)
	touch $@

.stage.%.newlib-make: .stage.%.newlib-config
	cd $(call arena,$@)/newlib; $(call setenv,$@); $(MAKE)
	cd $(call arena,$@)/newlib; $(call setenv,$@); $(MAKE) install
	touch $@

.stage.%.libstdcpp: .stage.%.newlib-make
	# stage 2 (build libstdc++)
	cd $(call arena,$@)/gcc; $(call setenv,$@); $(MAKE)
	cd $(call arena,$@)/gcc; $(call setenv,$@); $(MAKE) install
	touch $@

.stage.%.libsdtcpp-nox: .stage.%.libstdcpp
	# We copy existing stdc, adjust the makefile, and build a single .a to save much time
	rm -rf $(call arena,$@)/gcc/xtensa-lx106-elf/libstdc++-v3-nox
	cp -a $(call arena,$@)/gcc/xtensa-lx106-elf/libstdc++-v3 $(call arena,$@)/gcc/xtensa-lx106-elf/libstdc++-v3-nox
	cd $(call arena,$@)/gcc/xtensa-lx106-elf/libstdc++-v3-nox; $(call setenv,$@); $(MAKE) clean; find . -name Makefile -exec sed -i 's/mlongcalls/mlongcalls -fno-exceptions/' \{\} \; ; $(MAKE)
	cp $(call arena,$@)/gcc/xtensa-lx106-elf/libstdc++-v3-nox/src/.libs/libstdc++.a xtensa-lx106-elf$(call ext,$@)/xtensa-lx106-elf/lib/libstdc++-nox.a
	touch $@

.stage.%.hal-config: .stage.%.libsdtcpp-nox
	rm -rf $(call arena,$@)/hal
	mkdir -p $(call arena,$@)/hal
	cd $(call arena,$@)/hal; $(call setenv,$@); $(REPODIR)/lx106-hal/configure --host=xtensa-lx106-elf $$(echo $(call configure,$@) | sed 's/--host=[a-zA-Z0-9_-]*//')
	touch $@

.stage.%.hal-make: .stage.%.hal-config
	cd $(call arena,$@)/hal; $(call setenv,$@); $(MAKE)
	cd $(call arena,$@)/hal; $(call setenv,$@); $(MAKE) install
	touch $@

.stage.%.strip: .stage.%.hal-make
	$(call setenv,$@); $(call host,$@)-strip $(call install,$@)/bin/*$(call exe,$@) $(call install,$@)/libexec/gcc/xtensa-lx106-elf/*/c*$(call exe,$@) $(call install,$@)/libexec/gcc/xtensa-lx106-elf/*/lto1$(call exe,$@) || true
	touch $@

.stage.%.post: .stage.%.strip
	for sh in post/$(GCC)*.sh; do \
	    [ -x "$${sh}" ] && $${sh} $(call ext,$@) ; \
	done
	touch $@

.stage.%.package: .stage.%.post
	rm -rf pkg.$(call arch,$@)
	mkdir -p pkg.$(call arch,$@)
	cp -a $(call install,$@) pkg.$(call arch,$@)/xtensa-lx106-elf
	tarball=$(call host,$@).xtensa-lx106-elf-$$(git rev-parse --short HEAD).$(call tarext,$@) ; \
	cd pkg.$(call arch,$@) && $(call tarcmd,$@) $(call taropt,$@) ../$${tarball} xtensa-lx106-elf/ ; cd ..; $(call makejson,$@)
	rm -rf pkg.$(call arch,$@)
	touch $@

.stage.%.mkspiffs: .stage.%.start
	rm -rf $(call arena,$@)/mkspiffs
	cp -a $(REPODIR)/mkspiffs $(call arena,$@)/mkspiffs
	cd $(call arena,$@)/mkspiffs;\
	    $(call setenv,$@); \
	    TARGET_OS=$(call mktgt,$@) CC=$(call host,$@)-gcc CXX=$(call host,$@)-g++ STRIP=$(call host,$@)-strip \
            $(MAKE) clean mkspiffs$(call exe,$@) BUILD_CONFIG_NAME="-arduino-esp8266" CPPFLAGS="-DSPIFFS_USE_MAGIC_LENGTH=0 -DSPIFFS_ALIGNED_OBJECT_INDEX_TABLES=1"
	rm -rf pkg.mkspiffs.$(call arch,$@)
	mkdir -p pkg.mkspiffs.$(call arch,$@)/mkspiffs
	cp $(call arena,$@)/mkspiffs/mkspiffs$(call exe,$@) pkg.mkspiffs.$(call arch,$@)/mkspiffs/.
	tarball=$(call host,$@).mkspiffs-$$(cd $(REPODIR)/mkspiffs && git rev-parse --short HEAD).$(call tarext,$@) ; \
	cd pkg.mkspiffs.$(call arch,$@) && $(call tarcmd,$@) $(call taropt,$@) ../$${tarball} mkspiffs; cd ..; $(call makejson,$@)
	rm -rf pkg.mkspiffs.$(call arch,$@)
	touch $@

.stage.%.esptool: .stage.%.start
	rm -rf $(call arena,$@)/esptool
	cp -a $(REPODIR)/esptool $(call arena,$@)/esptool
	cd $(call arena,$@)/esptool;\
	    $(call setenv,$@); \
	    TARGET_OS=$(call mktgt,$@) CC=$(call host,$@)-gcc CXX=$(call host,$@)-g++ STRIP=$(call host,$@)-strip \
            $(MAKE) clean esptool$(call exe,$@) BUILD_CONFIG_NAME="-arduino-esp8266"
	rm -rf pkg.esptool.$(call arch,$@)
	mkdir -p pkg.esptool.$(call arch,$@)/esptool
	cp $(call arena,$@)/esptool/esptool$(call exe,$@) pkg.esptool.$(call arch,$@)/esptool/.
	tarball=$(call host,$@).esptool-$$(cd $(REPODIR)/esptool && git rev-parse --short HEAD).$(call tarext,$@) ; \
	cd pkg.esptool.$(call arch,$@) && $(call tarcmd,$@) $(call taropt,$@) ../$${tarball} esptool; cd ..; $(call makejson,$@)
	rm -rf pkg.esptool.$(call arch,$@)
	touch $@

.stage.%.done: .stage.%.package .stage.%.mkspiffs .stage.%.esptool
	rm -rf $(call arena,$@)
	echo Done building $(call arch,$@)

# Only the native version has to be done to install libs to GIT
install: .stage.LINUX.install
.stage.LINUX.install:
	rm -rf $(ARDUINO)
	git clone https://github.com/$(GHUSER)/Arduino $(ARDUINO)
	echo "-------- Building installable newlib"
	rm -rf arena/newlib-install; mkdir -p arena/newlib-install
	cd arena/newlib-install; $(call setenv,$@); $(REPODIR)/newlib/configure $(CONFIGURENEWLIBINSTALL); $(MAKE); $(MAKE) install
	echo "-------- Building installable hal"
	rm -rf arena/hal-install; mkdir -p arena/hal-install
	cd arena/hal-install; $(call setenv,$@); $(REPODIR)/lx106-hal/configure --prefix=$(ARDUINO)/tools/sdk/libc --libdir=$(ARDUINO)/tools/sdk/lib --host=xtensa-lx106-elf $$(echo $(call configure,$@) | sed 's/--host=[a-zA-Z0-9_-]*//' | sed 's/--prefix=[a-zA-Z0-9_-\\]*//')
	cd arena/hal-install; $(call setenv,$@); $(MAKE) ; $(MAKE) install
	echo "-------- Copying GCC libs"
	cp $(call install,$@)/lib/gcc/xtensa-lx106-elf/*/libgcc.a  $(ARDUINO)/tools/sdk/lib/.
	cp $(call install,$@)/xtensa-lx106-elf/lib/libstdc++.a     $(ARDUINO)/tools/sdk/lib/.
	cp $(call install,$@)/xtensa-lx106-elf/lib/libstdc++-nox.a $(ARDUINO)/tools/sdk/lib/.
	echo "-------- Copying toolchain directory"
	rm -rf $(ARDUINO)/tools/sdk/xtensa-lx106-elf
	cp -a $(call install,$@)/xtensa-lx106-elf $(ARDUINO)/tools/sdk/xtensa-lx106-elf
	echo "-------- Updating package.json"
	ver=$(REL)-$(SUBREL)-$(shell git rev-parse --short HEAD); pkgfile=$(ARDUINO)/package/package_esp8266com_index.template.json; \
	./patch_json.py --pkgfile "$${pkgfile}" --tool xtensa-lx106-elf-gcc --ver "$${ver}" --glob '*xtensa-lx106-elf*.json' ; \
	./patch_json.py --pkgfile "$${pkgfile}" --tool esptool --ver "$${ver}" --glob '*esptool*json' ; \
	./patch_json.py --pkgfile "$${pkgfile}" --tool mkspiffs --ver "$${ver}" --glob '*mkspiffs*json'
	echo "Install done"

# Upload a draft toolchain release
upload: .stage.LINUX.upload
.stage.LINUX.upload:
	rm -rf ./venv; mkdir ./venv
	virtualenv --no-site-packages venv
	cd ./venv; . bin/activate; \
	    pip install -q pygithub ; \
	    python ../upload_release.py --user "$(GHUSER)" --pw "$(GHPASS)" --tag $(REL)-$(SUBREL) --msg 'See https://github.com/esp8266/Arduino for more info'  --name "ESP8266 Quick Toolchain for $(REL)-$(SUBREL)" ../*.tar.gz ../*.zip ;
	rm -rf ./venv

dumpvars:
	echo SETENV:    '$(call setenv,.stage.LINUX.stage)'
	echo CONFIGURE: '$(call configure,.stage.LINUX.stage)'
	echo NEWLIBCFG: '$(call configurenewlib,.stage.LINUX.stage)'
