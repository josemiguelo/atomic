#!/bin/bash

set -ouex pipefail

echo "::group:: ===$(basename "$0")==="

rpm --import https://packages.microsoft.com/keys/microsoft.asc &&
  echo -e "[code]
name=Visual Studio Code
baseurl=https://packages.microsoft.com/yumrepos/vscode
enabled=1
autorefresh=1
type=rpm-md
gpgcheck=1
gpgkey=https://packages.microsoft.com/keys/microsoft.asc" |
  tee /etc/yum.repos.d/vscode.repo >/dev/null
dnf5 install -y code

echo "::endgroup::"
