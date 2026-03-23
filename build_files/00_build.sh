#!/bin/bash

set -ouex pipefail

mapfile -t scripts < <(printf '%s\n' /ctx/build_scripts/[0-9]*.sh | sort -V)
for script in "${scripts[@]}"; do
  [[ "$(basename "$script")" == "00_build.sh" ]] && continue
  "$script"
done

echo "::group:: === enabling services ==="
systemctl enable podman.socket
systemctl enable --global /usr/lib/systemd/user/post-install-checker.service
systemctl enable /usr/lib/systemd/system/custom-groups.service
echo "::endgroup::"

dnf5 clean all
echo "🚀 Installation complete!"
