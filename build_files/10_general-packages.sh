#!/bin/bash

set -ouex pipefail

echo "::group:: ===$(basename "$0")==="

GENERAL_PACKAGES=(
  "vlc"
  "konsole"
  "okular"
  "dbus-devel"
  "dnf-command(copr)"
  "solaar"
)
dnf5 install -y "${GENERAL_PACKAGES[@]}"

rm -f /etc/xdg/autostart/solaar.desktop

echo "::endgroup::"
