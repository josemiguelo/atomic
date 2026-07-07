#!/bin/bash

set -ouex pipefail

echo "::group:: ===$(basename "$0")==="

curl -1sLf -o /tmp/teams-for-linux.asc https://repo.teamsforlinux.de/teams-for-linux.asc
rpm --import /tmp/teams-for-linux.asc
curl -1sLf -o /etc/yum.repos.d/teams-for-linux.repo https://repo.teamsforlinux.de/rpm/teams-for-linux.repo
dnf5 -y install teams-for-linux

echo "::endgroup::"
