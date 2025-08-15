#!/bin/bash
set -euo pipefail

required_packages=(
  "avahi"
  "nss-mdns"
  "openssh"
)

if ! command -v iwctl &> /dev/null; then
  required_packages+=(iwd)
fi

echo -e "⏳ Installing required packages for networking module..."
sudo pacman -S --noconfirm --needed "${required_packages[@]}"
echo -e "✅ Networking module required packages installed"

# Disable multicast dns in resolved
sudo mkdir -p /etc/systemd/resolved.conf.d
echo -e "[Resolve]\nMulticastDNS=no" | sudo tee /etc/systemd/resolved.conf.d/10-disable-multicast.conf

IWD_MAIN_CONFIG_FILE="/etc/iwd/main.conf"
if [ ! -f "${IWD_MAIN_CONFIG_FILE}" ]; then
  sudo tee "${IWD_MAIN_CONFIG_FILE}" <<'EOF'
[General]
EnableNetworkConfiguration=false
EOF
fi

# Set Cloudflare as primary DNS (with Google as backup)
sudo cp ~/.local/share/anarchy/default/systemd/resolved.conf /etc/systemd/

services_to_enable=(
  "iwd"
  "sshd"
  "avahi-daemon"
  "systemd-networkd"
  "systemd-resolved"
)

for service in "${services_to_enable[@]}"; do
  if ! systemctl is-active --quiet "${service}.service"; then
    echo -e "🔧 Enabling $service service..."
    sudo systemctl enable --now "${service}.service"
    echo -e "✅ $service service enabled"
  fi
done

NETWORK_SVC_CONF_DIR="/etc/systemd/system/systemd-networkd-wait-online.service.d"
CONF_FILE="${NETWORK_SVC_CONF_DIR}/wait-for-any-interface.conf"

echo "🔧 Disabling systemd-networkd-wait-online.service..."
if [ -f "${CONF_FILE}" ]; then
  sudo rm "${CONF_FILE}"
fi
sudo systemctl disable systemd-networkd-wait-online.service
sudo systemctl mask systemd-networkd-wait-online.service

echo -e "✅ Networking module setup complete!\n"
sleep 3
clear