[group('PostInstall')]
setup-asdf:
  #!/bin/bash
  set -ex

  # INSTALLATION
  cd $HOME

  ASDF_VERSION="0.18.0"
  BIN_DIR="$HOME/.local/bin"
  ASDF_DATA_DIR="$HOME/.asdf"
  CHEZMOI_DIR="$HOME/.local/share/chezmoi"

  if command -v asdf >/dev/null 2>&1; then
    echo "✅ asdf version $(asdf --version) is already installed. Skipping download."
  else
    echo "🚀 asdf not found. Starting installation of v${ASDF_VERSION}..."

    ARCH=$(uname -m)
    case ${ARCH} in
    x86_64) ARCH_TYPE="amd64" ;;
    aarch64) ARCH_TYPE="arm64" ;;
    *)
      echo "❌ Unsupported architecture: ${ARCH}"
      exit 1
      ;;
    esac

    mkdir -p "$BIN_DIR"
    mkdir -p "$ASDF_DATA_DIR"/{installs,plugins,shims}

    URL="https://github.com/asdf-vm/asdf/releases/download/v${ASDF_VERSION}/asdf-v${ASDF_VERSION}-linux-${ARCH_TYPE}.tar.gz"

    echo "🚀 Downloading from: ${URL}"
    curl -sSL "$URL" | tar -xz -C "$BIN_DIR" asdf

    chmod +x "${BIN_DIR}/asdf"
    chmod -R u+rwX,go+rX,go-w "$ASDF_DATA_DIR"

    echo "🚀 Installation complete. asdf binary placed in ${BIN_DIR}/asdf."
    echo "version $(asdf --version)"
  fi

  # PLUGINS
  if asdf plugin list | grep -q "^asdf-plugin-manager$"; then
    echo "✅ asdf-plugin-manager plugin is already installed."
  else
    asdf plugin add asdf-plugin-manager https://github.com/asdf-community/asdf-plugin-manager.git
    asdf install asdf-plugin-manager 1.5.0 # sync this version with asdf config files
  fi

  PLUGIN_MANAGER="$ASDF_DATA_DIR/shims/asdf-plugin-manager"
  echo "✅ installed asdf-plugin-manager version $($PLUGIN_MANAGER version)"

  if [ -f ~/.tool-versions ]; then
    $PLUGIN_MANAGER add-all
    asdf install
  else
    echo "❌ ~/.tool-versions not found. There was a problem with the chezmoi setup..."
    exit 1
  fi

  # CHEZMOI REMOTES
  if [ -d "$CHEZMOI_DIR" ]; then
    DESIRED_REMOTE="git@github.com:josemiguelo/.dotfiles.git"
    CURRENT_REMOTE=$(cd "$CHEZMOI_DIR" && git remote get-url origin 2>/dev/null)
    if [ "$CURRENT_REMOTE" != "$DESIRED_REMOTE" ]; then
      echo "🚀 Setting chezmoi git remote to $DESIRED_REMOTE..."
      (cd "$CHEZMOI_DIR" && git remote set-url origin "$DESIRED_REMOTE" && echo "✅ remote set successfully")
    else
      echo "✅ chezmoi git remote is already set correctly."
    fi
  else
    echo "❌ $CHEZMOI_DIR not found. There was a problem with the chezmoi setup..."
    exit 1
  fi
