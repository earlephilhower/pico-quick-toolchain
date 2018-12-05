#/bin/bash

gcc=${1:-4.8}
rel=${rel:-2.5.0}
subrel=${subrel:-2}

echo Multiarch build for: ${gcc} ${rel}-${subrel}

cd /workdir

./build distclean
for host in linux win64 win32 osx arm64 rpi; do
	gcc=${gcc} host=${host} rel=${rel} subrel=${subrel} ./build build
	./build clean
done

gcc=${gcc} host=${host} rel=${rel} subrel=${subrel} ./build install

pass=$(cat .ghpass)
rm -rf ./venv
mkdir ./venv
virtualenv --no-site-packages venv
pushd ./venv
source bin/activate
pip install -q pygithub
python ../upload_release.py --user earlephilhower --pw "${pass}" --tag ${rel}-${subrel} --msg 'See https://github.com/esp8266/Arduino for more info'  --name "ESP8266 Quick Toolchain for ${rel}-${subrel}" ../*.tar.gz ../*.zip
deactivate
popd
rm -rf ./venv
