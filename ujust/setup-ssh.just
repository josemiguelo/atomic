[group('PostInstall')]
setup-ssh:
  #!/bin/bash
  set -ex

  SSH_KEY="$HOME/.ssh/bazzite"
  if [ ! -f "$SSH_KEY" ]; then
    echo "🚀 Creating SSH key 'bazzite'..."
    ssh-keygen -t ed25519 -C "josemiguelo.ochoa@gmail.com" -f "$SSH_KEY" -N ""
    eval "$(ssh-agent -s)"
    ssh-add "$SSH_KEY"
    echo "✅ Done creating SSH key 'bazzite'"
  else
    echo "⚠️ SSH key 'bazzite' already exists."
  fi

  SSH_CONFIG="$HOME/.ssh/config"
  touch "$SSH_CONFIG"
  chmod 600 "$SSH_CONFIG"
  if ! grep -q "AddKeysToAgent yes" "$SSH_CONFIG"; then
    echo "🚀 Adding AddKeysToAgent rule to $SSH_CONFIG..."
    printf '\nHost *\n    AddKeysToAgent yes\n    IdentityFile %s\n' "$SSH_KEY" >> "$SSH_CONFIG"
    echo "✅ Done configuring SSH agent auto-add."
  else
    echo "⚠️ AddKeysToAgent already configured in $SSH_CONFIG."
  fi
