####################################################################################################
[group('PostInstall')]
setup-brews:
  #!/bin/bash
  set -ex

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
  brew install anomalyco/tap/opencode

  brew cleanup

  echo "✅ Done installing brews"
