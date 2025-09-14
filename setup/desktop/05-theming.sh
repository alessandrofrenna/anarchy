#!/bin/bash
set -euo pipefail

packages=(
  "gnome-themes-extra" "qqc2-desktop-style" "kvantum-qt5"
  "kvantum-theme-libadwaita-git" "qt5ct" "qt6ct"
)

echo -e "⏳ Installing theme customization packages..."
yay -S --noconfirm --needed "${packages[@]}"
sudo pacman -S --noconfirm --needed adw-gtk-theme
if ! yay -Q yaru-icon-theme &>/dev/null; then
  yay -S --noconfirm --needed yaru-icon-theme
fi
echo -e "✅ Theme customization packages installed"

echo -e "🎨 Customizing Adwaita theme settings..."
if command -v gsettings >/dev/null 2>&1; then
  gsettings set org.gnome.desktop.interface cursor-theme 'default'
  
  # Set fonts
  gsettings set org.gnome.desktop.interface font-name 'Inter Nerd Font Propo Regular 12'
  gsettings set org.gnome.desktop.interface document-font-name 'Inter Nerd Font Propo Regular 12'
  gsettings set org.gnome.desktop.interface monospace-font-name 'JetBrainsMono Nerd Font Regular 12'
fi
echo -e "✅ Adwaita theme settings changed"

GTK_3_SETTINGS="${HOME}/.config/gtk-3.0/settings.ini"
if [ -f "${GTK_3_SETTINGS}" ]; then
  # sudo rm /usr/share/gtk-3.0/settings.ini
  sudo ln -snf "${GTK_3_SETTINGS}" /usr/share/gtk-3.0/settings.ini
fi

ANARCHY_CONF_DIR="${HOME}/.config/anarchy"
ANARCHY_THEME_DIR="${ANARCHY_CONF_DIR}/theme"
BTOP_THEMES_DIR="${HOME}/.config/btop/themes"
if [ ! -d "${ANARCHY_THEME_DIR}" ]; then
  mkdir -p "${ANARCHY_THEME_DIR}"
  mkdir -p "${BTOP_THEMES_DIR}"
fi

# --- Helper function to parse TOML ---
# A simple grep/sed parser for the key-value pairs in theme.toml
# Usage: get_toml_value <file> <key>
get_toml_value() {
  local file="$1"
  local key="$2"
  # Grep for the key, then use sed to remove the key, equals sign, spaces, and quotes.
  grep "^${key} *=" "${file}" | sed -e "s/${key} *= *\"//g" -e 's/"$//g'
}

CURRENT_THEME_CONFIG="${ANARCHY_THEME_DIR}/theme.toml"
if [ ! -f "${CURRENT_THEME_CONFIG}" ]; then
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

  # Mako
  ln -snf "${ANARCHY_THEME_DIR}/mako.ini" "${HOME}/.config/mako/config"
  # Btop
  ln -snf "${ANARCHY_THEME_DIR}/btop.theme" "${BTOP_THEMES_DIR}/current.theme"
  # Kvantum
  ln -snf "${ANARCHY_THEME_DIR}/kvantum.kvconfig" "${HOME}/.config/Kvantum"

  echo -e "✅ Default theme setup completed\n"
fi

# Run this every time ensuring gsettings are in sync with theme.toml.
if [ -f "${CURRENT_THEME_CONFIG}" ]; then
  echo "⚙️ Applying GTK settings from ${CURRENT_THEME_CONFIG}..."

  # Read values from theme.toml using our helper function
  THEME_NAME=$(get_toml_value "${CURRENT_THEME_CONFIG}" "name")
  ICON_THEME=$(get_toml_value "${CURRENT_THEME_CONFIG}" "icon_theme")
  ACCENT_COLOR=$(get_toml_value "${CURRENT_THEME_CONFIG}" "accent_color")
  VARIANT=$(get_toml_value "${CURRENT_THEME_CONFIG}" "variant")

  # Validate that we got the values
  if [ -z "$THEME_NAME" ] || [ -z "$ICON_THEME" ] || [ -z "$ACCENT_COLOR" ] || [ -z "$VARIANT" ]; then
    echo "❌ Error: Could not parse all required settings from ${CURRENT_THEME_CONFIG}."
    echo "   Ensure 'name', 'icon_theme', 'accent_color', and 'dark' are set."
    exit 1
  fi

  # Determine GTK theme and color scheme based on the 'dark' setting
  if [ "${VARIANT}" == "dark" ]; then
      GTK_THEME="adw-gtk3-dark"
      COLOR_SCHEME="prefer-dark"
  else
      GTK_THEME="adw-gtk3"
      COLOR_SCHEME="default"
  fi

  # Apply settings using gsettings
  gsettings set org.gnome.desktop.interface gtk-theme "${GTK_THEME}"
  gsettings set org.gnome.desktop.interface color-scheme "${COLOR_SCHEME}"
  gsettings set org.gnome.desktop.interface icon-theme "${ICON_THEME}"
  gsettings set org.gnome.desktop.interface accent-color "${ACCENT_COLOR}"

  # Apply theme to flatpak
  sudo flatpak override --filesystem=/usr/share/themes

  echo "✅ Settings applied for theme: ${THEME_NAME}"
else
  echo "⚠️ Warning: Theme configuration file not found at ${CURRENT_THEME_CONFIG}. Applying default GTK settings."
  gsettings set org.gnome.desktop.interface gtk-theme "Adwaita-dark"
  gsettings set org.gnome.desktop.interface color-scheme "prefer-dark"
  gsettings set org.gnome.desktop.interface icon-theme "Yaru-blue"
  gsettings set org.gnome.desktop.interface accent-color "blue"
fi

sleep 3
clear