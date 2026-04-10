#!/bin/bash

set -ouex pipefail

echo "::group:: ===$(basename "$0")==="

curl -fsSL https://downloads.1password.com/linux/keys/1password.asc -o /tmp/1password.asc
rpm --import /tmp/1password.asc --import https://downloads.1password.com/linux/keys/1password.asc
dnf5 config-manager addrepo \
  --id=1password \
  --set=name="1Password Stable Channel" \
  --set=baseurl="https://downloads.1password.com/linux/rpm/stable/\$basearch" \
  --set=enabled=1 \
  --set=gpgcheck=1 \
  --set=repo_gpgcheck=1 \
  --set=gpgkey="file:///tmp/1password.asc"

dnf5 makecache --repo=1password
dnf5 install -y 1password

echo "::endgroup::"
