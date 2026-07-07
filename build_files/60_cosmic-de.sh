#!/bin/bash

set -ouex pipefail

exit 0 # don't use comic desktop for now.

echo "::group:: ===$(basename "$0")==="

dnf5 install -y @cosmic-desktop-environment
echo "COSMIC desktop installed successfully"

systemctl disable cosmic-greeter || true
systemctl enable gdm
echo "Display manager configured"

dnf5 install -y xdg-desktop-portal-cosmic
echo "Additional utilities installed"

echo "::endgroup::"
