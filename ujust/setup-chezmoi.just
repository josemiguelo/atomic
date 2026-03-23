[group('PostInstall')]
setup-chezmoi:
  #!/bin/bash
  set -ex

  if [ ! -d "$HOME/.local/share/chezmoi" ]; then
    echo "🚀 Initializing dotfiles in isolated home: $HOME"

    sudo chown -R $USER:$USER "$HOME/.local"
    chezmoi init --apply --verbose --force https://github.com/josemiguelo/.dotfiles.git
    echo "return { color_scheme = 'Tokyo Night' }" >"$HOME/.config/wezterm/private.lua"

    echo "✅ chezmoi dotfiles downloaded and applied"
  else

    echo "✅ Dotfiles have already been initialized!"
  fi
