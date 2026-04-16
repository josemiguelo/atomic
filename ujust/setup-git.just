[group('PostInstall')]
setup-git:
  #!/bin/bash
  set -ex

  DESIRED_EMAIL="josemiguelo.ochoa@gmail.com"
  DESIRED_NAME="Jose Miguel Ochoa"

  CURRENT_EMAIL=$(git config --global user.email 2>/dev/null || true)
  CURRENT_NAME=$(git config --global user.name 2>/dev/null || true)

  if [ -z "$CURRENT_EMAIL" ]; then
    echo "🚀 Setting git user.email to $DESIRED_EMAIL..."
    git config --global user.email "$DESIRED_EMAIL"
  else
    echo "✅ git user.email is already set to: $CURRENT_EMAIL"
  fi

  if [ -z "$CURRENT_NAME" ]; then
    echo "🚀 Setting git user.name to $DESIRED_NAME..."
    git config --global user.name "$DESIRED_NAME"
  else
    echo "✅ git user.name is already set to: $CURRENT_NAME"
  fi

  git config --global core.pager delta
  git config --global interactive.diffFilter 'delta --color-only'
  git config --global delta.navigate true
  git config --global merge.conflictStyle zdiff3
