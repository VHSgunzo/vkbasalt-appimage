#!/usr/bin/env bash

apt install -y \
  libx11-dev \
  glslang-dev \
  meson \
  glslang-tools \
  cmake \
  pkg-config \
  gcc \
  g++ \
  gcc-multilib \
  g++-multilib \
  spirv-headers \
  libvulkan-dev

dpkg --add-architecture i386
apt update
apt install -y libx11-dev:i386
