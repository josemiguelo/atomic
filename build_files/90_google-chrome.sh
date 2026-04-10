#!/bin/bash

set -ouex pipefail

echo "::group:: ===$(basename "$0")==="
dnf5 install -y fedora-workstation-repositories
dnf5 config-manager setopt google-chrome.enabled=1
dnf5 install -y google-chrome-stable
echo "::endgroup::"
