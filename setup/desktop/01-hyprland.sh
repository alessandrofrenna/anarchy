#!/bin/bash
set -euo pipefail

hyprland_required_packages=(
  "uwsm"
  "libnewt"
  "hyprland"
  "xdg-desktop-portal-hyprland"
  "xdg-desktop-portal-gtk"  
  "polkit-gnome"
  "libsecret"
  "libgnome-keyring"
  "gnome-keyring"
)

echo -e "⏳ Installing hyprland required packages..."
sudo pacman -S --noconfirm --needed "${hyprland_required_packages[@]}"
echo -e "✅ Hyprland required packages installed"

utility_packages=(
  "waybar"
  "walker-bin"
  "mako"
  "swaybg"
  "hyprlock"
  "hypridle"
  "hyprcursor"
  "swayosd"
  "brightnessctl"
  "hyprshot"
  "hyprland-qtutils"
  "hyprland-qt-support"
  "wl-clipboard"
  "wl-clip-persist"
  "seahorse"
)

echo -e "⏳ Installing hyprland utility packages..."
yay -S --noconfirm "${utility_packages[@]}"
echo -e "✅ Hyprland utility packages installed"

# Copy hyprland configuration
cp -R "${HOME}/.local/share/anarchy/default/config/hypr" "${HOME}/.config"

HYPR_CONFIG_DIR="${HOME}/.config/hypr"

HYPR_USER_CONFIGS="${HYPR_CONFIG_DIR}/${USER}"
if [ ! -d "${HYPR_USER_CONFIGS}" ]; then
  mkdir -p "${HYPR_USER_CONFIGS}"
fi

HYPR_USER_CONFIG_FILE="${HYPR_USER_CONFIGS}/custom.conf"
if [ ! -f "${HYPR_USER_CONFIG_FILE}" ]; then
  touch "${HYPR_USER_CONFIG_FILE}"
fi

HYPR_DEFAULT_CONFIG_FILE="${HYPR_CONFIG_DIR}/hyprland.conf"
if ! grep -i -E "\s*source\s*=.*/${USER}/custom.conf" "${HYPR_DEFAULT_CONFIG_FILE}"; then
  echo -e "\nsource = ~/.config/hypr/${USER}/custom.conf" | tee -a "${HYPR_DEFAULT_CONFIG_FILE}" >/dev/null
fi

# Use iGPU as rendered
"${HOME}/.local/share/anarchy/bin/use-integrated-gpu"

# Enable hyprland utilities as services
services=(
  "hypridle.service"
  "waybar.service"
  "mako.service"
)

echo -e "🔧 Enabling UWSM hyprland services..."
for service in "${services[@]}"; do
  # Check if the service is active or enabled at the user level
  if ! systemctl --user is-enabled --quiet "$service"; then
    echo -e "🔧 Enabling $service..."
    systemctl --user enable "$service"
    echo -e "✅ $service enabled"
  fi
done
echo -e "✅ UWSM hyprland services enabled\n"
sleep 3
clear