####################################################################################################
[group('PostInstall')]
setup-flatpaks:
  #!/bin/bash
  set -ex

  is_bootc=false
  if [ -f /run/ostree-booted ]; then
    is_bootc=true
  fi

  flatpak_cmd=("flatpak")
  if [ "$is_bootc" = "false" ]; then
    flatpak_cmd+=("--user")
  fi

  remove_flatpak() {
    local app_id=$1
    if "${flatpak_cmd[@]}" info "$app_id" >/dev/null 2>&1; then
      "${flatpak_cmd[@]}" uninstall --delete-data "$app_id" -y
      echo "✅ Removed $app_id..."
    else
      echo "⚠️ $app_id flatpak is not present on the system. skipping uninstallation..."
    fi
  }

  install_flatpak() {
    local app_id=$1
    local app_name=$2
    if "${flatpak_cmd[@]}" info "$app_id" >/dev/null 2>&1; then
      echo "⚠️ $app_name is already installed."
    else
      echo "🚀 Installing $app_name..."
      if "${flatpak_cmd[@]}" install -y "$app_id"; then
        echo "✅ Success: $app_name installed"
      else
        echo "❌ Error: Failed to install $app_name. Proceeding with remainder of script..."
      fi
    fi
  }

  # flatpaks
  echo "🚀 Configuring flatpaks..."

  # Ensure flathub remote is added
  "${flatpak_cmd[@]}" remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo

  remove_flatpak "org.mozilla.firefox"
  install_flatpak "md.obsidian.Obsidian" "Obsidian"

  echo "✅ Done installing flatpaks"
