import "./setup-brews.just"
import "./setup-chezmoi.just"
import "./setup-asdf.just"
import "./setup-git.just"
import "./download-fonts.just"
import "./setup-ngrok.just"
import "./setup-completions.just"

[group('PostInstall')]
do-post-install: \
  setup-brews \
  setup-chezmoi \
  setup-asdf \
  setup-git \
  download-fonts \
  setup-ngrok \
  setup-completions
