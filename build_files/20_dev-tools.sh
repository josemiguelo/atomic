#!/bin/bash

set -ouex pipefail

echo "::group:: ===$(basename "$0")==="

dnf5 install -y @development-tools
DEV_PACKAGES=(
  "zlib-devel"
  "bzip2-devel"
  "readline-devel"
  "sqlite"
  "sqlite-devel"
  "openssl-devel"
  "xz-devel"
  "libffi-devel"
  "findutils"
  "tk-devel"
  "libzstd-devel"
  "autoconf"
  "gcc"
  "rust"
  "patch"
  "libyaml-devel"
  "gdbm-devel"
  "ncurses-devel"
  "perl-FindBin"
)
echo "Installing dev packages ${#DEV_PACKAGES[@]} ..."
dnf5 install -y "${DEV_PACKAGES[@]}"

echo "::endgroup::"
