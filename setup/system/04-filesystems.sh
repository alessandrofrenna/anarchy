#!/bin/bash
set -euo pipefail

required_packages=(
  "gvfs"
  "gvfs-mtp"
  "gvfs-afc"
  "gvfs-gphoto2"
  # Microsoft filesystems
  "exfatprogs"
  "dosfstools"
  "ntfs-3g"
  # Fuse filesystems
  "fuse2"
  "fuse3"
  "sshfs"
  "fuseiso"
  # External drives
  "udisks2"
  "udiskie"
  # User directories
  "xdg-user-dirs"
)

echo -e "⏳ Installing required packages for filesystems module..."
sudo pacman -S --noconfirm --needed "${required_packages[@]}"
echo -e "✅ Filesystems module required packages installed"

if ! systemctl is-active --quiet udisks2.service; then
  echo -e "🔧 Enabling udisks2 service..."
  sudo systemctl enable --now udisks2.service
  echo -e "✅ udisks2 service enabled"
fi

echo -e "✅ Filesystems module setup complete!\n"
sleep 3
clear