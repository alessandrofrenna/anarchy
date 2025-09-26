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
  "rofi"
)

echo -e "⏳ Installing hyprland required packages..."
sudo pacman -S --noconfirm --needed "${hyprland_required_packages[@]}"
echo -e "✅ Hyprland required packages installed"

utility_packages=(
  "waybar"
  "mako"
  "swaybg"
  "hyprlock"
  "hypridle"
  "hyprsunset"
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
yay -S --noconfirm --needed "${utility_packages[@]}"
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

echo -e "🔧 Enabling swayosd-libinput-backend as service..."
if ! systemctl is-enabled --quiet "swayosd-libinput-backend.service"; then
  echo -e "🔧 Enabling swayosd-libinput-backend..."
  systemctl enable --now swayosd-libinput-backend.service
  echo -e "✅ swayosd-libinput-backend enabled"
fi
echo -e "✅ swayosd-libinput-backend enabled\n"

# Enable hyprland utilities as services
services=(
  "hypridle.service"
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