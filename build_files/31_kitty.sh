#!/bin/bash

set -ouex pipefail

echo "::group:: ===$(basename "$0")==="
dnf5 copr enable -y solopasha/kitty
dnf5 install -y kitty
echo "::endgroup::"
