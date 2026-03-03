#!/bin/bash

set -ouex pipefail

while IFS= read -r script; do
  [[ "$(basename "$script")" == "00_build.sh" ]] && continue
  echo "::group:: === Running $(basename "$script") ==="
  "$script"
  echo "::endgroup::"
done < <(printf '%s\n' /ctx/build_scripts/[0-9]*.sh | sort -V)

echo "::group:: === enabling services ==="
systemctl enable podman.socket
systemctl enable --global /usr/lib/systemd/user/post-install-checker.service
systemctl enable /usr/lib/systemd/user/custom-groups.service
echo "::endgroup::"

dnf5 clean all
echo "🚀 Installation complete!"
