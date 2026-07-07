#!/bin/bash

set -ouex pipefail

echo "::group:: ===$(basename "$0")==="

tee /etc/yum.repos.d/antigravity.repo <<EOF
[antigravity-rpm]
name=Antigravity RPM Repository
baseurl=https://us-central1-yum.pkg.dev/projects/antigravity-auto-updater-dev/antigravity-rpm
enabled=1
gpgcheck=0
EOF
dnf5 makecache --repo=antigravity-rpm
dnf5 install -y antigravity

echo "::endgroup::"
