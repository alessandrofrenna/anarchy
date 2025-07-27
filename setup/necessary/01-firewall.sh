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

# 2. Set default policies (these commands are idempotent)
echo "🔧 Setting default firewall policies..."
sudo ufw default deny incoming
sudo ufw default allow outgoing

# 3. Add SSH rule if it doesn't exist
# The output of 'ufw status' looks like: "22/tcp ALLOW IN Anywhere"
if ! sudo ufw status | grep -q "^22/tcp\s*ALLOW"; then
  echo "🔧 Adding firewall rule for SSH..."
  sudo ufw allow 22/tcp
fi

# 4. Enable the firewall if it's inactive
if ! sudo ufw status | grep -q "Status: active"; then
  echo "🧱 Enabling firewall..."
  # 'ufw enable' is interactive; use 'yes' to auto-confirm
  yes | sudo ufw enable
  echo -e "✅ Firewall enabled"
else
  echo "✅ Firewall is already active"
fi

echo -e "\n✅ Completed Firewall configuration\n"
sleep 3
clear