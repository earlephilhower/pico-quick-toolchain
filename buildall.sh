#docker run ubuntu

apt-get update
apt-get install -y gcc g++ make flex bison texinfo autogen mingw-w64 git libgmp3-dev libmpfr-dev libmpc-dev zlib1g-dev clang wget autoconf
cd /workdir
git clone https://github.com/earlephilhower/osxcross
cd osxcross
cd tarballs
wget https://github.com/phracker/MacOSX-SDKs/releases/download/10.13/MacOSX10.10.sdk.tar.xz
xz -d MacOSX10.10.sdk.tar.xz
bzip2 -1 MacOSX10.10.sdk.tar
cd ..
UNATTENDED=1 ./build.sh
UNATTENDED=1 GCC_VERSION=7.3.0 ./build_gcc.sh
cd ..;
export PATH=$(pwd)/osxcross/target/bin:$PATH

git clone https://github.com/earlephilhower/esp-quick-toolchain
cd esp-quick-toolchain
./build build native

./build clean
./build build win64

./build clean
./build build win32

./build clean
./build build osx


