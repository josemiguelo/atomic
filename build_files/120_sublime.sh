#!/bin/bash

set -ouex pipefail

echo "::group:: ===$(basename "$0")==="

rpm -v --import https://download.sublimetext.com/sublimehq-rpm-pub.gpg
dnf5 config-manager addrepo --from-repofile=https://download.sublimetext.com/rpm/stable/$(uname -m)/sublime-text.repo
dnf5 makecache --repo=sublime-text
dnf5 install -y sublime-text

echo "::endgroup::"
