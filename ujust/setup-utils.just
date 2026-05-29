[group('PostInstall')]
setup-utils:
  #!/bin/bash
  set -ex

  BIN_DIR="$HOME/.local/bin"
  mkdir -p "$BIN_DIR"

  # jumpkwapp
  JUMPKWAPP_VERSION="v0.01"
  ACTION="installed"
  if [[ -x "$BIN_DIR/jumpkwapp" ]]; then
    echo "jumpkwapp already exists. Replacing..."
    ACTION="replaced"
  fi
  curl -fSL "https://github.com/josemiguelo/jumpkwapp-go/releases/download/${JUMPKWAPP_VERSION}/jumpkwapp-linux-amd64" -o "$BIN_DIR/jumpkwapp"
  chmod +x "$BIN_DIR/jumpkwapp"
  echo "jumpkwapp ${JUMPKWAPP_VERSION} ${ACTION} at $BIN_DIR/jumpkwapp"

  # JetBrains Toolbox scripts
  JETBRAINS_SCRIPTS_DIR="$HOME/.local/share/JetBrains/Toolbox/scripts"
  if [[ -d "$JETBRAINS_SCRIPTS_DIR" ]]; then
    for script in "$JETBRAINS_SCRIPTS_DIR"/*; do
      [[ -f "$script" ]] || continue
      name="$(basename "$script")"
      ln -sf "$script" "$BIN_DIR/$name"
      echo "Symlinked $name -> $script"
    done
  else
    echo "JetBrains Toolbox scripts directory not found, skipping"
  fi
