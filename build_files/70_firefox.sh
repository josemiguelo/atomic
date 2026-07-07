#!/bin/bash

set -ouex pipefail

echo "::group:: ===$(basename "$0")==="
dnf5 config-manager setopt fedora-cisco-openh264.enabled=1
dnf5 install -y firefox --allowerasing
echo "::endgroup::"

