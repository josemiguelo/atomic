[group('PostInstall')]
download-fonts:
  #!/bin/bash
  set -ex

  if [[ "$(uname)" == "Darwin" ]]; then
    fonts_target_path=~/Library/Fonts
  else
    fonts_target_path=~/.local/share/fonts
  fi

  # Check if FiraCode fonts are already installed
  if ls "$fonts_target_path"/Fira\ Code* 1>/dev/null 2>&1; then
    echo "✅ FiraCode fonts are already installed. Skipping download."
    exit 0
  fi

  TEMP_DIR=$(mktemp -d)
  cd $TEMP_DIR

  echo "🚀 downloading nerd fonts at $TEMP_DIR/ ..."
  wget https://github.com/ryanoasis/nerd-fonts/releases/download/v2.3.3/FiraCode.zip -P $TEMP_DIR/

  echo "🚀 unziping FiraCode to $TEMP_DIR/FiraCode/ ..."
  unzip $TEMP_DIR/FiraCode.zip -d $TEMP_DIR/FiraCode

  echo "🚀 copying fonts to $fonts_target_path/ ..."
  mkdir -p $fonts_target_path
  cp $TEMP_DIR/FiraCode/Fira\ Code* $fonts_target_path/

  # macOS registers fonts placed in ~/Library/Fonts automatically; fc-cache only exists on Linux.
  if [[ "$(uname)" != "Darwin" ]]; then
    echo "updating fonts cache..."
    fc-cache -fv
  fi

  echo "✅ FiraCode fonts installed."
