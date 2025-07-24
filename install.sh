#!/bin/bash
set -euo pipefail
# Give people a chance to retry running the installation
trap 'echo -e "\033cAnarchy installation failed! You can retry by running: source ~/.local/share/anarchy/install.sh\n"' ERR

# Enable pacman ILoveCandy and Color
if ! grep -q "^\s*ILoveCandy" /etc/pacman.conf; then
    sudo sed -i '/^\[options\]/a ILoveCandy' /etc/pacman.conf
fi
if ! grep -q "^\s*Color" /etc/pacman.conf; then
    sudo sed -i '/^\[options\]/a Color' /etc/pacman.conf
fi

# Enable multilib for 32-bit support if not enabled
if ! grep -q "^\s*\[multilib\]" /etc/pacman.conf; then
  sudo sed -i '/^#\[multilib\]/{s/^#//;n;s/^#//}' /etc/pacman.conf
  sudo pacman -Syy
fi

sudo pacman -S --noconfirm --needed base-devel &>/dev/null
clear

# Install yay if needed
if ! command -v yay &>/dev/null; then
  echo -e "📦 Installing yay AUR helper..."
  cd /tmp
  git clone https://aur.archlinux.org/yay-bin.git
  cd yay-bin
  makepkg -si --noconfirm
  cd /
  rm -rf /tmp/yay-bin
  echo -e "✅ yay AUR helper installed successfully"
else
  echo -e "\033c📦 AUR helper found: yay"
fi

SETUP_DIR="${HOME}/.local/share/anarchy/setup"
script_dirs=(
  "${SETUP_DIR}/necessary"
  "${SETUP_DIR}/system"
  "${SETUP_DIR}/desktop"
)
for directory in "${script_dirs[@]}"; do
  for script in "${directory}/"*; do
    source "${script}"
  done
done

# Ensure locate is up to date now that everything has been installed
echo -e "\033c⏳ Updating database..."
sudo updatedb

# Remove orphaned packages and clean cache
ORPHANS=$(pacman -Qtdq || true)
if [ -n "${ORPHANS}" ]; then
  echo -e "⏳Removing orphans..."
  sudo pacman -Rns --noconfirm "${ORPHANS}"
else
  echo -e "✅ No orphan package to remove"
fi

echo -e "⏳ Cleaning cache..."
yes | yay -Scc
echo -e "✅ Cache cleared"
sleep 3

echo -e "\033c✅ Anarchy setup completed rebooting system now!"
sleep 2
sudo systemctl reboot