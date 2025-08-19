#!/bin/bash
set -euo pipefail

required_packages=(
  "avahi"
  "nss-mdns"
  "openssh"
  "dnsutils"
)

if ! command -v iwctl &> /dev/null; then
  required_packages+=(iwd)
fi

echo -e "⏳ Installing required packages for networking module..."
sudo pacman -S --noconfirm --needed "${required_packages[@]}"
echo -e "✅ Networking module required packages installed"

IWD_MAIN_CONFIG_FILE="/etc/iwd/main.conf"
if [ ! -f "${IWD_MAIN_CONFIG_FILE}" ]; then
  echo "🔧 Configuring iwd to delegate network setup to systemd-networkd..."
  sudo tee "${IWD_MAIN_CONFIG_FILE}" <<'EOF'
[General]
EnableNetworkConfiguration=false
EOF
fi

# Set DNS and enable DNS over TLS
echo "🔧 Setting up systemd-resolved for secure DNS..."
sudo cp ~/.local/share/anarchy/default/systemd/resolved.conf /etc/systemd/
# Ensure /etc/resolv.conf is linked correctly:
if [ "$(readlink /etc/resolv.conf)" != "/run/systemd/resolve/stub-resolv.conf" ]; then
  echo "🔧 Correcting /etc/resolv.conf symlink..."
  sudo mv /etc/resolv.conf /etc/resolv.conf.bak
  sudo ln -nsf /run/systemd/resolve/stub-resolv.conf /etc/resolv.conf
fi
echo "✅ systemd-resolved configured."

readonly NETWORK_DIR="/etc/systemd/network"
readonly BACKUP_DIR="${NETWORK_DIR}.bak"
readonly NETWORK_CONFIG_FILENAME="20-anarchy.network"
readonly NETWORK_CONFIG_FILE=~/.local/share/anarchy/default/systemd/network/${NETWORK_CONFIG_FILENAME}
readonly DROP_IN_DIR="${NETWORK_DIR}/${NETWORK_CONFIG_FILENAME}.d"
readonly STATIC_CONFIG_PLACEHOLDER="${DROP_IN_DIR}/30-anarchy-static.conf"

if [ ! -d "${BACKUP_DIR}" ]; then
  echo "🔧 Performing first-time network file setup..."
  # 1. Create backup directory and move existing configurations
  sudo mkdir -p "${BACKUP_DIR}"
  # Safely move any existing .network files to the backup folder
  sudo find "${NETWORK_DIR}" -maxdepth 1 -name "*.network" -exec mv -t "${BACKUP_DIR}/" {} +

  # 2. Copy the new generic network file
  echo "🔧 Installing generic network configuration..."
  sudo cp "${NETWORK_CONFIG_FILE}" "${NETWORK_DIR}"

  # 3. Create the drop-in directory
  echo "🔧 Creating drop-in directory for overrides..."
  sudo mkdir -p "${DROP_IN_DIR}"

  # 4. Create the placeholder file for static IP settings
  echo "🔧 Creating placeholder for future static IP configuration..."
  sudo tee "${STATIC_CONFIG_PLACEHOLDER}" <<'EOF'
# This is a placeholder for a static IP configuration.
# To use a static IP, uncomment the lines below and fill in your details.
# The settings here will override the DHCP settings from the main file.

#[Network]
#Address=192.168.1.40/24
#Gateway=192.168.1.1

#[DHCP]
#DHCP=no
EOF
  
  echo "✅ Network file setup complete."
else
  echo "ℹ️ Network backup directory already exists, skipping file setup."
fi

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
  else
    echo -e "🔧 Restarting $service service..."
    sudo systemctl restart "${service}.service"
    echo -e "✅ $service service restarted"
  fi
done

echo "🔧 Disabling systemd-networkd-wait-online.service..."
NETWORK_SVC_CONF_DIR="/etc/systemd/system/systemd-networkd-wait-online.service.d"
CONF_FILE="${NETWORK_SVC_CONF_DIR}/wait-for-any-interface.conf"
if [ -f "${CONF_FILE}" ]; then
  sudo rm "${CONF_FILE}"
fi
sudo systemctl disable systemd-networkd-wait-online.service
sudo systemctl mask systemd-networkd-wait-online.service
echo "✅ systemd-networkd-wait-online.service disabled."

echo -e "✅ Networking module setup complete!\n"
sleep 3
clear