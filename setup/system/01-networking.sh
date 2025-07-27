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

services_to_enable=(
  "iwd"
  "sshd"
  "avahi-daemon"
)

for service in "${services_to_enable[@]}"; do
  if ! systemctl is-active --quiet "${service}.service"; then
    echo -e "🔧 Enabling $service service..."
    sudo systemctl enable --now "${service}.service"
    echo -e "✅ $service service enabled"
  fi
done

# Fix systemd-networkd-wait-online timeout for multiple interfaces
# Wait for any interface to be online rather than all interfaces
# https://wiki.archlinux.org/title/Systemd-networkd#Multiple_interfaces_that_are_not_connected_all_the_time
NETWORK_SVC_CONF_DIR="/etc/systemd/system/systemd-networkd-wait-online.service.d"
CONF_FILE="${NETWORK_SVC_CONF_DIR}/wait-for-any-interface.conf"

echo "🔧 Configuring systemd-networkd-wait-online.service..."
if [ ! -f "${CONF_FILE}" ]; then
  sudo mkdir -p "${NETWORK_SVC_CONF_DIR}"
  sudo tee "${CONF_FILE}" >/dev/null <<EOF
[Service]
ExecStart=
ExecStart=/usr/lib/systemd/systemd-networkd-wait-online --any
EOF
  echo "✅ Created override for systemd-networkd-wait-online.service"
else
  echo "✅ Override for systemd-networkd-wait-online.service already exists."
fi

echo -e "✅ Networking module setup complete!\n"
sleep 3
clear