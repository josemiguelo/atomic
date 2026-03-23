#!/bin/bash

set -ouex pipefail

echo "::group:: ===$(basename "$0")==="

# NOTE: although this says fedora 21, this is where latest versions are being uploaded.
# latest versions are being installed correctly on fedora  j.
rpm --import https://packagecloud.io/slacktechnologies/slack/gpgkey
cat <<'EOF' | tee /etc/yum.repos.d/slack.repo
[slack]
name=Slack
baseurl=https://packagecloud.io/slacktechnologies/slack/fedora/21/$basearch
enabled=1
gpgcheck=0
repo_gpgcheck=0
gpgkey=https://packagecloud.io/slacktechnologies/slack/gpgkey
sslverify=1
sslcacert=/etc/pki/tls/certs/ca-bundle.crt
metadata_expire=300
EOF
dnf5 makecache --repo=slack
dnf5 -y install slack

echo "::endgroup::"
