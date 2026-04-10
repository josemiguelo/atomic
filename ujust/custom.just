import "./setup-flatpaks.just"
import "./setup-brews.just"
import "./setup-chezmoi.just"
import "./setup-asdf.just"
import "./setup-steam.just"
import "./setup-ssh.just"
import "./setup-git.just"
import "./download-fonts.just"
import "./setup-ngrok.just"
import "./setup-completions.just"
import "./install-cursor.just"

[group('PostInstall')]
do-post-install: \
  setup-flatpaks \
  setup-brews \
  setup-chezmoi \
  setup-asdf \
  setup-steam \
  setup-ssh \
  setup-git \
  download-fonts \
  setup-ngrok \
  setup-completions \
  install-cursor
