#!/bin/bash
set -euo pipefail

remove_any_other_dm() {
  local display_managers=("sddm" "gdm" "lightdm" "lxdm")
  local removed_any=false
  
  for dm in "${display_managers[@]}"; do
    if pacman -Qi "$dm" &>/dev/null; then
        echo "🔍 Found display manager: $dm"
        echo "🗑️ Removing $dm..."
        sudo systemctl stop "$dm" 2>/dev/null || true
        sudo systemctl disable "$dm" 2>/dev/null || true
        sudo pacman -Rns --noconfirm "$dm" 2>/dev/null || true
        removed_any=true
    fi
  done

  if [[ "$removed_any" == true ]]; then
    echo "✅ Display managers removed"
  else
    echo "✅ No display managers found to remove"
  fi
}

install_ly_dm() {
  echo -e "⏳ Installing ly display manager..."
  sudo pacman -S --noconfirm --needed ly
  echo -e "✅ ly display manager installed"
}

echo -e "🖥️ Configuring display manager"
if ! pacman -Qi ly &>/dev/null; then
  install_ly_dm
else
  echo -e "✅ ly display manager already installed"
fi

if ! systemctl is-enabled --quiet ly.service; then
  remove_any_other_dm
  sudo systemctl enable ly.service
  echo -e "✅ ly display manager service enabled"
else
  echo -e "✅ ly display manager already enabled"
fi

echo -e "✅ Display manager configured\n"
sleep 3
clear