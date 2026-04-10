[group('PostInstall')]
install-cursor:
  #!/bin/bash
  set -ex

  curl https://cursor.com/install -fsS | bash
