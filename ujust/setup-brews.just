####################################################################################################
[group('PostInstall')]
setup-brews:
  #!/bin/bash
  set -ex

  # Load homebrew environment if it exists
  if [ -d "/home/linuxbrew/.linuxbrew" ]; then
    eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
  elif [ -d "$HOME/.linuxbrew" ]; then
    eval "$("$HOME/.linuxbrew/bin/brew" shellenv)"
  fi

  export NONINTERACTIVE=1
  export HOMEBREW_NO_AUTO_UPDATE=1

  echo "🚀 Configuring brews..."

  brew install yq
  brew install atuin
  brew install btop
  brew install bat
  brew install ripgrep
  brew install zoxide
  brew install chezmoi
  brew install fd
  brew install trash-cli
  brew install tree-sitter-cli
  brew install tmux
  brew install tmuxpack/tpack/tpack
  brew install git-delta
  brew install lazygit
  brew install lazydocker
  brew install starship
  brew install anomalyco/tap/opencode
  brew install yazi

  if [ -f /run/ostree-booted ]; then
    brew tap ublue-os/tap
    brew trust ublue-os/tap
    brew install --cask jetbrains-toolbox-linux
  fi

  brew cleanup

  echo "✅ Done installing brews"
