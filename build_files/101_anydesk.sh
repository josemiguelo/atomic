#!/bin/bash

set -ouex pipefail

echo "::group:: ===$(basename "$0")==="

curl -1sLf -o /tmp/anydesk.rpm https://download.anydesk.com/linux/anydesk_8.0.2-1_x86_64.rpm
dnf5 -y install /tmp/anydesk.rpm
rm -f /tmp/anydesk.rpm

echo "::endgroup::"
