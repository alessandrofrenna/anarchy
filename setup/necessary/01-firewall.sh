#!/bin/bash
set -euo pipefail

# Original reference https://github.com/basecamp/omarchy/blob/dev/install/firewall.sh
# ======================================================================================
# Based on Omarchy script: firewall
# ======================================================================================


# 1. Install UFW if it's missing
if ! command -v ufw &>/dev/null; then
  echo -e "⏳ Installing UFW..."
  sudo pacman -S --noconfirm --needed ufw
  echo -e "✅ UFW installed"
fi

# 5. Enable the firewall if it's inactive
if ! sudo ufw status | grep -q "Status: active"; then
  echo "🧱 Enabling firewall..."
  # 'ufw enable' is interactive; use 'yes' to auto-confirm
  sudo systemctl enable --now ufw
  sudo ufw --force enable 
  echo -e "✅ Firewall enabled"

  # Set default policies (these commands are idempotent)
  echo "🔧 Setting default firewall policies..."
  sudo ufw default deny incoming
  sudo ufw default allow outgoing
fi


# 1. Add SSH rule if it doesn't exist
# The output of 'ufw status' looks like: "22/tcp ALLOW IN Anywhere"
if ! sudo ufw status | grep -q "^22/tcp\s*ALLOW"; then
  echo "🔧 Adding firewall rule for SSH..."
  sudo ufw allow 22/tcp
fi

# 2. Add DNS-over-TLS rule if it doesn't exist
if ! sudo ufw status | grep -q "853/tcp.*ALLOW OUT"; then
  echo "🔧 Adding firewall rule for outbound DNS over TLS..."
  sudo ufw allow out 853/tcp comment 'Allow outbound DNS over TLS'
fi

sudo ufw reload

echo -e "✅ Completed Firewall configuration\n"

sleep 3
clear

