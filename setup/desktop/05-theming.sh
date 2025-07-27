#!/bin/bash
set -euo pipefail

packages=(
  "gnome-themes-extra" "qqc2-desktop-style" "kvantum-qt5"
  "morewaita-icon-theme" "adwaita-colors-icon-theme"
  "kvantum-theme-libadwaita-git"
)

echo -e "⏳ Installing theme customization packages..."
yay -S --noconfirm "${packages[@]}"
echo -e "✅ Theme customization packages installed"

echo -e "🎨 Customizing Adwaita theme settings..."
if command -v gsettings >/dev/null 2>&1; then
  gsettings set org.gnome.desktop.interface gtk-theme "Adwaita-dark"
  gsettings set org.gnome.desktop.interface color-scheme "prefer-dark"
  gsettings set org.gnome.desktop.interface cursor-theme 'default'
  # Set icons
  gsettings set org.gnome.desktop.interface icon-theme 'Adwaita-pink'
  gsettings set org.gnome.desktop.interface accent-color 'pink'

  # Enable symbolic folder icons (commented for now)
  # gsettings set org.gnome.desktop.interface icon-theme-use-symbolic true 2>/dev/null || true
  
  # Set fonts
  gsettings set org.gnome.desktop.interface font-name "Inter Nerd Font, 12"
  gsettings set org.gnome.desktop.interface document-font-name 'Inter Nerd Font 12'
  gsettings set org.gnome.desktop.interface monospace-font-name 'JetBrainsMono Nerd Font 12'

fi
echo -e "✅ Adwaita theme settings changed"

ANARCHY_CONF_DIR="${HOME}/.config/anarchy"
ANARCHY_THEME_DIR="${ANARCHY_CONF_DIR}/theme"
ANARCHY_THEME_CURRENT="${ANARCHY_THEME_DIR}/.name"
BTOP_THEMES_DIR="${HOME}/.config/btop/themes"
if [ ! -d "${ANARCHY_THEME_DIR}" ]; then
  mkdir -p "${ANARCHY_THEME_DIR}"
  mkdir -p "${BTOP_THEMES_DIR}"
  touch "${ANARCHY_THEME_CURRENT}"
fi

if [ ! -s "${ANARCHY_THEME_CURRENT}" ]; then
  THEMES_DIR="${HOME}/.local/share/anarchy/themes"
  ANARCHY_DEFAULT_THEME_NAME="nord"
  ANARCHY_DEFAULT_BG_NAME="01-nord.png"
  echo -e "🎨 Setting default theme to ${ANARCHY_DEFAULT_THEME_NAME}..."
  # Set background
  ln -snf "${THEMES_DIR}/${ANARCHY_DEFAULT_THEME_NAME}/backgrounds/${ANARCHY_DEFAULT_BG_NAME}" "${ANARCHY_CONF_DIR}/current_background"
  # Link theme files
  for file in "${THEMES_DIR}/${ANARCHY_DEFAULT_THEME_NAME}"/*; do
    # This check prevents errors if the source directory is empty
    [ -e "$file" ] || [ -L "$file" ] || continue
    
    # Create a symbolic link for each file in the destination directory
    ln -snf "$file" "${ANARCHY_THEME_DIR}"
  done
  # Set current theme name file
  echo -e "${ANARCHY_DEFAULT_THEME_NAME}" > "${ANARCHY_THEME_CURRENT}"
  # Mako
  ln -snf "${ANARCHY_THEME_DIR}/mako.ini" "${HOME}/.config/mako/config"
  # Btop
  ln -snf "${ANARCHY_THEME_DIR}/btop.theme" "${BTOP_THEMES_DIR}/current.theme"
  echo -e "✅ Default theme setup completed\n"
else
  echo -e "\n"
fi

sleep 3
clear