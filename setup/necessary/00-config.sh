#!/bin/bash
set -euo pipefail

if ! pacman -Qi just &>/dev/null; then
  echo -e "⏳ Installing just..."
  sudo pacman -S --noconfirm --needed just
  echo -e "✅ just installed"
else
  echo -e "✅ just already installed"
fi

if [ ! -d "${HOME}/.config" ]; then
  mkdir "${HOME}/.config"
  echo "🗃️ Created missing ${HOME}/.config "
fi

echo -e "⏳ Copying configurations into ${HOME}/.config..."
# Loop through all files/directories in the anarchy/default/config folder
for item in "${HOME}/.local/share/anarchy/default/config/"*; do
  item_name="${item##*/}"
  # Check if the item is a directory named "hypr"
  if [ "${item_name}" != "hypr" ]; then
    # If it's not, copy it
    cp -R "${item}" "${HOME}/.config"
  fi
done
echo -e "✅ Configurations copied"

# Use default bashrc from Anarchy
echo -e "⏳ Configuring .bashrc file..."
cp ~/.local/share/anarchy/default/bashrc ~/.bashrc
echo -e "✅ .bashrc configured\n"

# Original reference https://github.com/basecamp/omarchy/blob/a4e7f41798148765055b2dcb5e70a680825688aa/install/4-config.sh#L12
# ======================================================================================
# Based on Omarchy script: 4-config.sh script
# ======================================================================================
# Setup GPG configuration with multiple keyservers for better reliability
# ======================================================================================
echo -e "🔑 Importing GPG keyservers..."

sudo mkdir -p /etc/gnupg
sudo cp ~/.local/share/anarchy/default/gpg/dirmngr.conf /etc/gnupg/
sudo chmod 644 /etc/gnupg/dirmngr.conf
sudo gpgconf --kill dirmngr || true
sudo gpgconf --launch dirmngr || true
echo -e "✅ GPG keyservers imported successfully"

sudo pacman -Sy archlinux-keyring

sleep 3
clear