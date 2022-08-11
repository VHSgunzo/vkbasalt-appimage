#!/usr/bin/env bash

GIT='https://github.com/DadSchoorse/vkBasalt.git'
GIT_RESHADE='https://github.com/VHSgunzo/reshade/releases'

if [[ -d ./git ]] ; then
  rm -Rf ./git
fi

git clone "$GIT" ./git
cd ./git
git describe --long --tags | sed 's/^v//;s/\([^-]*-g\)/r\1/;s/-/./g' > vkbasalt_version
wget "${GIT_RESHADE}$(curl -L -s "${GIT_RESHADE}"|grep -m1 -o '\/download.*.tar.gz')"
tar -xvf ./reshade.tar.gz

LDFLAGS=-static-libstdc++ meson --buildtype=release --prefix=$(pwd)/AppDir builddir
ninja -C builddir install

LDFLAGS=-static-libstdc++ ASFLAGS=--32 CFLAGS=-m32 CXXFLAGS=-m32 PKG_CONFIG_PATH=/usr/lib/i386-linux-gnu/pkgconfig meson --prefix=$(pwd)/AppDir --buildtype=release --libdir=lib/i386-linux-gnu -Dwith_json=false builddir.32
ninja -C builddir.32 install
