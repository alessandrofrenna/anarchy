#!/bin/bash
set -euo pipefail 
 
echo -e "⏳ Installing flatpak..."
sudo pacman -S --noconfirm --needed flatpak
echo -e "✅ flatpak installed"

# Enable timer to update installed flatpaks automatically
if ! systemctl is-enabled --user --quiet update-user-flatpaks.timer ; then
  echo -e "🔧 Enabling update-user-flatpaks timer..."
  systemctl --user enable --now update-user-flatpaks.timer
  echo -e "✅ update-user-flatpaks timer enabled"
fi

echo -e "✅ Completed flatpaks configuration\n"

sleep 3
clear