

rel     := $(if $(rel),$(rel),2.5.0)
subrel  := $(if $(subrel),$(subrel),2)
arduino := $(if $(arduino),$(arduino),$(shell pwd)/arduino)
gcc     := $(if $(gcc),$(gcc),4.8)

# For uploading, the GH user and password
user    := $(if $(pass),$(pass),earlephilhower)
pass    := $(if $(pass),$(pass),$(cat .ghpass))

ifeq ($(gcc),4.8)
	isl           := 0.12.2
	xtensa_branch := call0-4.8.2
else ifeq ($(gcc),4.9)
	isl           := 0.12.2
	xtensa_branch := call0-4.9.2
else ifeq ($(gcc),5.2)
	isl           := 0.12.2
	xtensa_branch := xtensa-ctng-esp-5.2.0
else ifeq ($(gcc),7.2)
	isl           := 0.16.1
	xtensa_branch := xtensa-ctng-7.2.0
else
	$(error Need to specify a supported GCC version)
endif
mkspiffs := 0.2.0

# if using LTO, in arduino's platform.txt -gcc-ar must be used instead of -ar
# -flto -Wl,-flto must be added in all {c, cpp, s}'s flags
lto := $(if $(lto),$(lto),false)

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

PWD = $(shell pwd)
REPODIR := $(PWD)/repo
PATCHDIR := $(PWD)/patches
arena = $(PWD)/arena$(call ext,$(1))

gccbuild  := $(shell gcc -dumpmachine)

arch = $(subst .,,$(suffix $(basename $(1))))

install = $(PWD)/xtensa-lx106-elf$($(call arch,$(1))_EXT)

configure  = --prefix=$(call install,$(1))
configure += --build=$(gccbuild)
configure += --host=$(call host,$(1))
configure += --target=xtensa-lx106-elf
configure += --disable-shared
configure += --with-newlib --enable-threads=no --disable-__cxa_atexit
configure += --disable-libgomp --disable-libmudflap --disable-nls --disable-multilib --enable-languages=c,c++
configure += --disable-bootstrap
configure += --enable-lto
configure += --disable-libstdcxx-verbose

configurenewlibcom  = --with-newlib --enable-multilib --disable-newlib-io-c99-formats --disable-newlib-supplied-syscalls
configurenewlibcom += --enable-newlib-nano-formatted-io --enable-newlib-reent-small --enable-target-optspace
configurenewlibcom += --disable-option-checking
configurenewlibcom += --target=xtensa-lx106-elf
configurenewlibcom += --disable-shared

configurenewlibinstall  = --prefix=$(arduino)/tools/sdk/libc --with-target-subdir=xtensa-lx106-elf
configurenewlibinstall += $(configurenewlibcom)

configurenewlib  = --prefix=$(call install,$(1))
configurenewlib += $(configurenewlibcom)

# Call with $@ to get the appropriate variable for this architecture
host  = $($(call arch,$(1))_HOST)
ahost = $($(call arch,$(1))_AHOST)
ext   = $($(call arch,$(1))_EXT)
exe   = $($(call arch,$(1))_EXE)
mktgt = $($(call arch,$(1))_MKTGT)

tarcmd = $(if ifeq(windows,$(call mktgt,$(1))),tar,zip)
taropt = $(if ifeq(windows,$(call mktgt,$(1))),zcf,-rq)
tarext = $(if ifeq(windows,$(call mktgt,$(1))),tar.gz,zip)

ifeq ($(LTO),"true")
  CFLAGS_FOR_TARGET   = CFLAGS_FOR_TARGET="-mlongcalls -flto -Wl,-flto -Os -g"
  CXXFLAGS_FOR_TARGET = CXXFLAGS_FOR_TARGET="-mlongcalls -flto -Wl,-flto -Os -g"
else
  CFLAGS_FOR_TARGET   = CFLAGS_FOR_TARGET="-mlongcalls -Os -g"
  CXXFLAGS_FOR_TARGET = CXXFLAGS_FOR_TARGET="-mlongcalls -Os -g"
endif

CFLAGS       = CFLAGS="-I$(call install,$(1))/include -pipe"
LDFLAGS      = LDFLAGS="-L$(call install,$(1))/lib"
NATIVEPATH   = PATH="$(call install,.stage.LINUX.stage)/bin:$${PATH}"
NATIVE_LDLIB = LD_LIBRARY_PATH="$(call install,.stage.LINUX.stage)/lib:$${LD_LIBRARY_PATH}"

setenv = export $(call CXXFLAGS_FOR_TARGET,$@); export $(call CFLAGS_FOR_TARGET,$(1)); export $(call CFLAGS,$(1)); export $(call LDFLAGS,$(1)); export $(call NATIVEPATH,$(1)); export $(call NATIVE_LDLIB,$(1));

# Generates a JSON fragment for an uploaded release artifact
makejson = tarballsize=$$(stat -c%s $${tarball}); tarballsha256=$$(sha256sum $${tarball} | cut -f1 -d" "); \
        ( echo '{' && \
          echo ' "host": "'$(call ahost,$(1))'",' && \
          echo ' "url": "https://github.com/earlephilhower/esp-quick-toolchain/releases/download/'$(rel)-$(subrel)'/'$${tarball}'",' && \
          echo ' "archiveFileName": "'$${tarball}'",' && \
          echo ' "checksum": "SHA-256:'$${tarballsha256}'",' && \
          echo ' "size": "'$${tarballsize}'"' && \
          echo '}') > $${tarball}.json

all: .stage.LINUX.done .stage.WIN32.done .stage.WIN64.done .stage.OSX.done .stage.ARM64.done .stage.RPI.done
	echo All complete

clean: .clean.gits
	rm -rf .stage* arena.* *.json *.tar.gz *.zip xtensa-lx106-elf.* venv arduino pkg.*

# Cross-compile cannot start until Linux is built
.stage.WIN32.start .stage.WIN64.start .stage.OSX.start .stage.ARM64.start .stage.RPI.start: .stage.LINUX.done

# Completely clean out a git directory, removing any untracked files
.clean.%.git:
	echo "Cleaning $@"
	test -d $(REPODIR)/$(call arch,$@) && cd $(REPODIR)/$(call arch,$@) && git reset --hard HEAD && git clean -f -d

.clean.gits: .clean.binutils-gdb.git .clean.gcc.git .clean.newlib.git .clean.newlib.git .clean.lx106-hal.git .clean.mkspiffs.git .clean.esptool.git

# Download the needed GIT and tarballs
gnuhttp := https://gcc.gnu.org/pub/gcc/infrastructure
.stage.download: .clean.gits
	mkdir -p $(REPODIR)
	test -d $(REPODIR)/binutils-gdb || git clone https://github.com/earlephilhower/binutils-gdb-xtensa.git $(REPODIR)/binutils-gdb
	test -d $(REPODIR)/gcc          || git clone https://github.com/earlephilhower/gcc-xtensa.git          $(REPODIR)/gcc
	test -d $(REPODIR)/newlib       || git clone https://github.com/earlephilhower/newlib-xtensa.git       $(REPODIR)/newlib
	test -d $(REPODIR)/lx106-hal    || git clone https://github.com/earlephilhower/lx106-hal.git           $(REPODIR)/lx106-hal
	test -d $(REPODIR)/mkspiffs     || git clone https://github.com/earlephilhower/mkspiffs.git            $(REPODIR)/mkspiffs
	test -d $(REPODIR)/esptool      || git clone https://github.com/earlephilhower/esptool-ck.git          $(REPODIR)/esptool
	for git in binutils-gdb gcc newlib lx106-hal mkspiffs esptool; do cd $(REPODIR)/$${url}; git pull; done
	for url in $(gnuhttp)/gmp-6.1.0.tar.bz2 $(gnuhttp)/mpfr-3.1.4.tar.bz2 $(gnuhttp)/mpc-1.0.3.tar.gz \
	           $(gnuhttp)/isl-$(isl).tar.bz2 $(gnuhttp)/cloog-0.18.1.tar.gz http://www.mr511.de/software/libelf-0.8.13.tar.gz ; do \
	    archive=$${url##*/}; name=$${archive%.t*}; base=$${name%-*}; ext=$${archive##*.} ; \
	    echo "-------- getting $${name}" ; \
	    cd $(REPODIR) && ( test -r $${archive} || wget $${url} ) ; \
	    case "$${ext}" in \
	        gz)  (cd $(REPODIR)/gcc; tar xfz ../$${archive});; \
	        bz2) (cd $(REPODIR)/gcc; tar xfj ../$${archive});; \
	    esac ; \
	    (cd $(REPODIR)/gcc; rm -f $${base}; ln -s $${name} $${base}) \
	done


# Checkout any required branches
.stage.checkout: .stage.download
	cd $(REPODIR)/gcc && git reset --hard && git checkout $(xtensa_branch)
	cd $(REPODIR)/mkspiffs && git reset --hard && git checkout $(mkspiffs) && git submodule update

# Apply our patches
.stage.patch: .stage.checkout
	echo "Patching source files"
	for p in $(PATCHDIR)/gcc-*.patch $(PATCHDIR)/gcc$(gcc)/gcc-*.patch; do \
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
	for p in $(PATCHDIR)/mkspiffs/$(mkspiffs)*.patch; do \
	    test -r "$$p" || continue ; \
	    (cd $(REPODIR)/mkspiffs; echo "---- $$p: "; patch -s -p1 < $$p) ; \
	done
	# dirty-force HAL definition to binutils and gcc
	for overwrite in $(REPODIR)/gcc/include/xtensa-config.h $(REPODIR)/binutils-gdb/include/xtensa-config.h; do \
	    ( cat $(REPODIR)/lx106-hal/include/xtensa/config/core-isa.h  $(REPODIR)/lx106-hal/include/xtensa/config/system.h ; \
	      echo '#define XCHAL_HAVE_FP_DIV 0' ; echo '#define XCHAL_HAVE_FP_RECIP 0' ; echo '#define XCHAL_HAVE_FP_SQRT 0' ; echo '#define XCHAL_HAVE_FP_RSQRT 0' ) > $${overwrite} ; \
        done
	cd $(REPODIR)/lx106-hal && autoreconf -i

.stage.LINUX.start:
	echo "Beginning native build"

.stage.%.start:
	echo "Beginning $(call arch,$@) build"

.stage.%.cleaninst: .stage.%.start
	rm -rf $(call install,$@)

# Build binutils
.stage.%.binutils: .stage.patch .stage.%.cleaninst
	rm -rf $(call arena,$@)/binutils-gdb
	mkdir -p $(call arena,$@)/binutils-gdb
	cd $(call arena,$@)/binutils-gdb; $(call setenv,$@) $(REPODIR)/binutils-gdb/configure $(call configure,$@)
	cd $(call arena,$@)/binutils-gdb; $(call setenv,$@) $(MAKE)
	cd $(call arena,$@)/binutils-gdb; $(call setenv,$@) $(MAKE) install
	cd $(call install,$@)/bin; ln -sf xtensa-lx106-elf-gcc$(call exe,$@) xtensa-lx106-elf-cc$(call exe,$@)

.stage.%.gcc1: .stage.%.binutils
	rm -rf $(call arena,$@)/gcc
	mkdir -p $(call arena,$@)/gcc
	cd $(call arena,$@)/gcc; $(call setenv,$@) $(REPODIR)/gcc/configure $(call configure,$@)
	cd $(call arena,$@)/gcc; $(call setenv,$@) $(MAKE) all-gcc; $(call setenv,$@) $(MAKE) install-gcc

.stage.%.newlib: .stage.%.gcc1
	rm -rf $(call arena,$@)/newlib
	mkdir -p $(call arena,$@)/newlib
	cd $(call arena,$@)/newlib; $(call setenv,$@) $(REPODIR)/newlib/configure $(call configurenewlib,$@)
	cd $(call arena,$@)/newlib; $(call setenv,$@) $(MAKE)
	cd $(call arena,$@)/newlib; $(call setenv,$@) $(MAKE) install

.stage.%.libstdcpp: .stage.%.newlib
	# stage 2 (build libstdc++)
	cd $(call arena,$@)/gcc; $(call setenv,$@) $(MAKE)
	cd $(call arena,$@)/gcc; $(call setenv,$@) $(MAKE) install

.stage.%.libsdtcpp-nox: .stage.%.libstdcpp
	# We copy existing stdc, adjust the makefile, and build a single .a to save much time
	rm -rf $(call arena,$@)/gcc/xtensa-lx106-elf/libstdc++-v3-nox
	cp -a $(call arena,$@)/gcc/xtensa-lx106-elf/libstdc++-v3 $(call arena,$@)/gcc/xtensa-lx106-elf/libstdc++-v3-nox
	cd $(call arena,$@)/gcc/xtensa-lx106-elf/libstdc++-v3-nox; $(call setenv,$@) $(MAKE) clean; find . -name Makefile -exec sed -i 's/mlongcalls/mlongcalls -fno-exceptions/' \{\} \; ; $(MAKE)
	cp $(call arena,$@)/gcc/xtensa-lx106-elf/libstdc++-v3-nox/src/.libs/libstdc++.a xtensa-lx106-elf$(call ext,$@)/xtensa-lx106-elf/lib/libstdc++-nox.a

.stage.%.hal: .stage.%.libsdtcpp-nox
	rm -rf $(call arena,$@)/hal
	mkdir -p $(call arena,$@)/hal
	cd $(call arena,$@)/hal; $(call setenv,$@) $(REPODIR)/lx106-hal/configure --host=xtensa-lx106-elf $$(echo $(call configure,$@) | sed 's/--host=[a-zA-Z0-9_-]*//')
	cd $(call arena,$@)/hal; $(call setenv,$@) $(MAKE)
	cd $(call arena,$@)/hal; $(call setenv,$@) $(MAKE) install

.stage.%.strip: .stage.%.hal
	$(call setenv,$@) $(call host,$@)-strip $(call install,$@)/bin/* $(call install,$@)/libexec/gcc/xtensa-lx106-elf/*/c* $(call install,$@)/libexec/gcc/xtensa-lx106-elf/*/lto1 || true

.stage.%.post: .stage.%.strip
	for sh in post/$(gcc)*.sh; do \
	    [ -x "$${sh}" ] && $${sh} $(call ext,$@) ; \
	done

.stage.%.package: .stage.%.post
	rm -rf pkg.$(call arch,$@)
	mkdir -p pkg.$(call arch,$@)
	cp -a $(call install,$@) pkg.$(call arch,$@)/xtensa-lx106-elf
	tarball=$(call host,$@).xtensa-lx106-elf-$$(git rev-parse --short HEAD).$(call tarext,$@) ; \
	cd pkg.$(call arch,$@) && $(call tarcmd,$@) $(call taropt,$@) ../$${tarball} xtensa-lx106-elf/ ; cd ..; $(call makejson,$@)
	rm -rf pkg.$(call arch,$@)

.stage.%.mkspiffs: .stage.%.package
	rm -rf $(call arena,$@)/mkspiffs
	cp -a $(REPODIR)/mkspiffs $(call arena,$@)/mkspiffs
	cd $(call arena,$@)/mkspiffs;\
	    $(call setenv,$@) \
	    TARGET_OS=$(call mktgt,$@) CC=$(call host,$@)-gcc CXX=$(call host,$@)-g++ STRIP=$(call host,$@)-strip \
            $(MAKE) clean mkspiffs$(call exe,$@) BUILD_CONFIG_NAME="-arduino-esp8266" CPPFLAGS="-DSPIFFS_USE_MAGIC_LENGTH=0 -DSPIFFS_ALIGNED_OBJECT_INDEX_TABLES=1"
	rm -rf pkg.mkspiffs.$(call arch,$@)
	mkdir -p pkg.mkspiffs.$(call arch,$@)/mkspiffs
	cp $(call arena,$@)/mkspiffs/mkspiffs$(call exe,$@) pkg.mkspiffs.$(call arch,$@)/mkspiffs/.
	tarball=$(call host,$@).mkspiffs-$$(cd $(REPODIR)/mkspiffs && git rev-parse --short HEAD).$(call tarext,$@) ; \
	cd pkg.mkspiffs.$(call arch,$@) && $(call tarcmd,$@) $(call taropt,$@) ../$${tarball} mkspiffs; cd ..; $(call makejson,$@)
	rm -rf pkg.mkspiffs.$(call arch,$@)

.stage.%.esptool: .stage.%.package
	rm -rf $(call arena,$@)/esptool
	cp -a $(REPODIR)/esptool $(call arena,$@)/esptool
	cd $(call arena,$@)/esptool;\
	    $(call setenv,$@) \
	    TARGET_OS=$(call mktgt,$@) CC=$(call host,$@)-gcc CXX=$(call host,$@)-g++ STRIP=$(call host,$@)-strip \
            $(MAKE) clean esptool$(call exe,$@) BUILD_CONFIG_NAME="-arduino-esp8266"
	rm -rf pkg.esptool.$(call arch,$@)
	mkdir -p pkg.esptool.$(call arch,$@)/esptool
	cp $(call arena,$@)/esptool/esptool$(call exe,$@) pkg.esptool.$(call arch,$@)/esptool/.
	tarball=$(call host,$@).esptool-$$(cd $(REPODIR)/esptool && git rev-parse --short HEAD).$(call tarext,$@) ; \
	cd pkg.esptool.$(call arch,$@) && $(call tarcmd,$@) $(call taropt,$@) ../$${tarball} esptool; cd ..; $(call makejson,$@)
	rm -rf pkg.esptool.$(call arch,$@)


.stage.%.done: .stage.%.package .stage.%.mkspiffs .stage.%.esptool
	rm -rf $(call arena,$@)
	echo Done building $(call arch,$@)


.stage.LINUX.install:
	rm -rf $(arduino)
	git clone https://github.com/earlephilhower/Arduino $(arduino)
	echo "-------- Building installable newlib"
	rm -rf arena/newlib-install; mkdir -p arena/newlib-install
	cd arena/newlib-install; $(call setenv,$@) $(REPODIR)/newlib/configure $(configurenewlibinstall); $(MAKE); $(MAKE) install
	echo "-------- Building installable hal"
	rm -rf arena/hal-install; mkdir -p arena/hal-install
	cd arena/hal-install; $(call setenv,$@) $(REPODIR)/lx106-hal/configure --prefix=$(arduino)/tools/sdk/libc --libdir=$(arduino)/tools/sdk/lib --host=xtensa-lx106-elf $$(echo $(call configure,$@) | sed 's/--host=[a-zA-Z0-9_-]*//' | sed 's/--prefix=[a-zA-Z0-9_-\\]*//')
	cd arena/hal-install; $(call setenv,$@) $(MAKE) ; $(MAKE) install
	echo "-------- Copying GCC libs"
	cp $(call install,$@)/lib/gcc/xtensa-lx106-elf/*/libgcc.a  $(arduino)/tools/sdk/lib/.
	cp $(call install,$@)/xtensa-lx106-elf/lib/libstdc++.a     $(arduino)/tools/sdk/lib/.
	cp $(call install,$@)/xtensa-lx106-elf/lib/libstdc++-nox.a $(arduino)/tools/sdk/lib/.
	echo "-------- Copying toolchain directory"
	rm -rf $(arduino)/tools/sdk/xtensa-lx106-elf
	cp -a $(call install,$@)/xtensa-lx106-elf $(arduino)/tools/sdk/xtensa-lx106-elf
	echo "-------- Updating package.json"
	ver=$(rel)-$(subrel)-$(shell git rev-parse --short HEAD); pkgfile=$(arduino)/package/package_esp8266com_index.template.json; \
	./patch_json.py --pkgfile "$${pkgfile}" --tool xtensa-lx106-elf-gcc --ver "$${ver}" --glob '*xtensa-lx106-elf*.json' ; \
	./patch_json.py --pkgfile "$${pkgfile}" --tool esptool --ver "$${ver}" --glob '*esptool*json' ; \
	./patch_json.py --pkgfile "$${pkgfile}" --tool mkspiffs --ver "$${ver}" --glob '*mkspiffs*json'
	echo "Install done"

.stage.LINUX.upload:
	rm -rf ./venv; mkdir ./venv
	virtualenv --no-site-packages venv;
	cd ./venv; source bin/activate; \
	    pip install -q pygithub ; \
	    python ../upload_release.py --user earlephilhower --pw "$(pass)" --tag $(rel)-$(subrel) --msg 'See https://github.com/esp8266/Arduino for more info'  --name "ESP8266 Quick Toolchain for $(rel)-$(subrel)" ../*.tar.gz ../*.zip ;
	rm -rf ./venv

dumpvars:
	echo SETENV:    '$(call setenv,.stage.LINUX.stage)'
	echo CONFIGURE: '$(call configure,.stage.LINUX.stage)'
	echo NEWLIBCFG: '$(call configurenewlib,.stage.LINUX.stage)'
