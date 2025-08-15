#!/bin/bash
set -euo pipefail

# Original reference https://github.com/basecamp/omarchy/blob/dev/install/firewall.sh
# ======================================================================================
# Based on Omarchy script: firewall
# ======================================================================================

kernel_pkg_name=$(pacman -Qo "/usr/lib/modules/$(uname -r)/"  | grep -v 'headers' | awk '{print $5}')
installed_kernel=$(pacman -Q "${kernel_pkg_name}" | awk '{print $2}')
running_kernel=$(uname -r | sed 's/-/\./')

if [ "${running_kernel}" != "${installed_kernel}" ]; then
  echo "============================================================"
  echo "❗️ KERNEL MISMATCH DETECTED"
  echo "   Running kernel:   ${running_kernel}"
  echo "   Installed kernel: ${installed_kernel}"
  echo "   Skipping firewall configuration to ensure system stability."
  echo "============================================================"
else
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

  # 4. Add DNS-over-TLS rule if it doesn't exist
  if ! sudo ufw status | grep -q "853/tcp.*ALLOW OUT"; then
    echo "🔧 Adding firewall rule for outbound DNS over TLS..."
    sudo ufw allow out 853/tcp comment 'Allow outbound DNS over TLS'
  fi

  # 5. Enable the firewall if it's inactive
  if ! sudo ufw status | grep -q "Status: active"; then
    echo "🧱 Enabling firewall..."
    # 'ufw enable' is interactive; use 'yes' to auto-confirm
    yes | sudo ufw enable
    echo -e "✅ Firewall enabled"
  else
    sudo ufw reload
    echo "✅ Firewall realoaded"
  fi
  echo -e "\n✅ Completed Firewall configuration\n"
fi
sleep 3
clear

