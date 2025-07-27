#!/bin/bash
set -euo pipefail

required_packages=(
  "pipewire"
  "pipewire-alsa"
  "pipewire-audio"
  "pipewire-pulse"
  "pipewire-zeroconf"
  "wireplumber"
  "sof-firmware"
  "playerctl"
)

echo -e "⏳ Installing required packages for audio..."
sudo pacman -S --noconfirm --needed "${required_packages[@]}"
echo -e "✅ Audio module required packages installed"

conflicting_services=(
  "pulseaudio.service"
  "pulseaudio.socket"
)

echo "🔧 Checking for conflicting audio services..."
for service in "${conflicting_services[@]}"; do
  # Check if the service is active or enabled at the user level
  if systemctl --user is-active --quiet "$service" || systemctl --user is-enabled --quiet "$service"; then
    echo -e "🔧 Disabling conflicting $service..."
    systemctl --user disable --now "$service"
    echo -e "✅ Conflicting $service disabled"
  fi
done

services_to_enable=(
  "pipewire.service"
  "pipewire.socket"
  "pipewire-pulse.service"
  "pipewire-pulse.socket"
  "wireplumber.service"
)

for service in "${services_to_enable[@]}"; do
  if ! systemctl is-active --user --quiet "${service}"; then
    echo -e "🔧 Enabling $service..."
    systemctl --user enable --now "${service}"
    echo -e "✅ $service enabled"
  fi
done

echo -e "✅ Audio module setup complete!\n"