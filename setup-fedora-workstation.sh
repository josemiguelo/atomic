#!/bin/bash

# Exit immediately if a command fails, treat pipeline states strictly
set -e
set -o pipefail

# Print commands for tracking/debugging
set -x

# 1. ROOT ELEVATION GUARANTEE
# Ensure the script triggers root privileges immediately so you don't mix contexts
if [ "$EUID" -ne 0 ]; then
  echo "This script modifies system configurations. Relaunching with sudo..."
  exec sudo -E "$0" "$@"
fi

# Track the original user for user-space configurations (Git, Flatpak, Just, and Brew)
ORIGINAL_USER="${SUDO_USER:-$(whoami)}"
ORIGINAL_HOME=$(eval echo "~$ORIGINAL_USER")

#####################
### CONFIGURE DNF ###
#####################
echo "=== [1/9] Configuring DNF Optimizations ==="
DNF_CONF="/etc/dnf/dnf.conf"

config_lines=(
  "fastestmirror=True"
  "max_parallel_downloads=10"
  "defaultyes=True"
  "keepcache=True"
)

changes_made=0
for line in "${config_lines[@]}"; do
  if ! grep -qxF "$line" "$DNF_CONF"; then
    echo "$line" >>"$DNF_CONF"
    changes_made=1
  fi
done

if [ "$changes_made" -eq 1 ]; then
  echo "[INFO] New configurations were added to $DNF_CONF."
else
  echo "[INFO] No changes needed. All configurations were already present."
fi

#######################
### GLOBAL PACKAGES ###
#######################
echo "=== [2/9] Installing Core Global Packages ==="
dnf install -y just vim-enhanced curl git procps-ng libxcrypt-compat zsh
dnf install -y @development-tools
dnf remove tmux bat

// virtualization
dnf install -y @virtualization
systemctl start libvirtd
systemctl enable libvirtd
usermod -a -G kvm $(whoami)

##################
### RPM FUSION ###
##################
echo "=== [3/9] Setting up RPM Fusion ==="
FEDORA_VERSION=$(rpm -E %fedora)

if rpm -q rpmfusion-free-release &>/dev/null; then
  echo "[-] RPM Fusion Free is already installed."
else
  echo "[+] Installing RPM Fusion Free..."
  dnf install -y "https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-${FEDORA_VERSION}.noarch.rpm"
fi

if rpm -q rpmfusion-nonfree-release &>/dev/null; then
  echo "[-] RPM Fusion Nonfree is already installed."
else
  echo "[+] Installing RPM Fusion Nonfree..."
  dnf install -y "https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-${FEDORA_VERSION}.noarch.rpm"
fi

dnf config-manager setopt fedora-cisco-openh264.enabled=1

##############
### CODECS ###
##############
echo "=== [4/9] Swapping Multimedia Codecs ==="
dnf swap ffmpeg-free ffmpeg --allowerasing -y
dnf group upgrade multimedia --exclude=PackageKit-gstreamer-plugin -y
dnf update @multimedia --setopt="install_weak_deps=False" --exclude=PackageKit-gstreamer-plugin -y

################
### FLATPAKS ###
################
echo "=== [5/9] Initializing Flathub ==="
# Run flatpak under the original user context so remotes attach to your user profile instead of root
sudo -u "$ORIGINAL_USER" flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo

#################
### T2 CONFIG ###
#################
echo "=== [6/9] Configuring Apple Keyboard options ==="
MODPROBE_CONF="/etc/modprobe.d/hid_apple.conf"

apple_options=(
  "options hid_apple swap_fn_leftctrl=1"
  "options hid_apple swap_opt_cmd=1"
)

file_modified=0
mkdir -p /etc/modprobe.d

for line in "${apple_options[@]}"; do
  if ! grep -qxF "$line" "$MODPROBE_CONF" 2>/dev/null; then
    echo "$line" >>"$MODPROBE_CONF"
    file_modified=1
  fi
done

if [ "$file_modified" -eq 1 ]; then
  echo "[INFO] $MODPROBE_CONF was modified. Regenerating initramfs with dracut..."
  dracut --regenerate-all --force
  echo "[SUCCESS] Initramfs regeneration complete. Reboot to apply changes."
else
  echo "[INFO] No changes needed. Apple keyboard options are already properly configured."
fi

##########################
### HOMEBREW (BLUEFIN) ###
##########################
echo "=== [7/9] Configuring Bluefin-Style Homebrew ==="

# 1. Install Brew if the directory doesn't exist yet
if [ ! -d "/home/linuxbrew/.linuxbrew" ]; then
  echo "[+] Downloading and installing Homebrew..."
  sudo -u "$ORIGINAL_USER" /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
else
  echo "[INFO] Homebrew directory already present under /home/linuxbrew/."
fi

# 2. Check and configure the global /etc/profile.d/ environment script
HOMEBREW_PROFILE="/etc/profile.d/homebrew.sh"

# If the file doesn't exist, or it exists but doesn't contain our brew initialization block
if [ ! -f "$HOMEBREW_PROFILE" ] || ! grep -q "brew shellenv" "$HOMEBREW_PROFILE"; then
  echo "[+] Generating global profile.d integration..."
  tee "$HOMEBREW_PROFILE" <<'EOF'
# Initialize Homebrew environment if the path exists globally
if [ -d "/home/linuxbrew/.linuxbrew" ]; then
    eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
fi
EOF
  chmod +x "$HOMEBREW_PROFILE"
  echo "[SUCCESS] Homebrew profile setup finalized globally."
else
  echo "[INFO] Global profile integration already present in $HOMEBREW_PROFILE (skipping append)."
fi

# 3. Dynamically inject brew into the current active script execution path
# This makes 'brew' immediately available to subsequent commands in this run
if [ -d "/home/linuxbrew/.linuxbrew" ]; then
  eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
fi

##########################
### ATOMIC BUILD FILES ###
##########################
echo "=== [8/9] Processing Repository Build Steps ==="
ATOMIC_PATH="$ORIGINAL_HOME/Repos/gh/josemiguelo/atomic"
BUILD_FILES_DIR="$ATOMIC_PATH/build_files"

# Secure directory cloning path as the actual user
if [ ! -d "$ATOMIC_PATH" ]; then
  sudo -u "$ORIGINAL_USER" mkdir -p "$ORIGINAL_HOME/Repos/gh/josemiguelo"
  sudo -u "$ORIGINAL_USER" git clone https://github.com/josemiguelo/atomic.git "$ATOMIC_PATH"
else
  echo "[INFO] Repository already cloned at $ATOMIC_PATH. Pulling updates..."
  sudo -u "$ORIGINAL_USER" git -C "$ATOMIC_PATH" pull
fi

# Ensure executable permissions are safe for scripts inside bin and build_files
if [ -d "$ATOMIC_PATH/system_files/usr/bin" ]; then
  chmod 755 "$ATOMIC_PATH/system_files/usr/bin"/*
fi
if [ -d "$BUILD_FILES_DIR" ]; then
  chmod +x "$BUILD_FILES_DIR"/*.sh
fi

# Iterate over the build steps folder cleanly using version sort
if [ -d "$BUILD_FILES_DIR" ]; then
  mapfile -t scripts < <(printf '%s\n' "$BUILD_FILES_DIR"/[0-9]*.sh | sort -V)
  for script in "${scripts[@]}"; do
    if [ -f "$script" ] && [ -x "$script" ] && [ "$(basename "$script")" != "00_build.sh" ]; then
      echo ""
      echo -e "\n[EXECUTING] ---> $(basename "$script")"
      echo "--------------------------------------------------"
      # Executed inline as root context natively
      "$script"
    fi
  done
fi

#########################
### ATOMIC JUST FILES ###
#########################
echo "=== [9/9] Orchestrating Post-Install Recipes ==="
# Run just using your user context so configuration changes land in your actual home folder
if [ -f "$ATOMIC_PATH/ujust/custom.just" ]; then
  sudo -u "$ORIGINAL_USER" just -f "$ATOMIC_PATH/ujust/custom.just" do-post-install
fi

######################
### FINAL UPGRADE  ###
######################
echo "=== Execution Finished. Syncing Packages ==="
dnf update -y
