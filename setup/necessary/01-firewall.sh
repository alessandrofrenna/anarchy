#!/bin/bash
set -euo pipefail

# Original reference https://github.com/basecamp/omarchy/blob/dev/install/firewall.sh
# ======================================================================================
# Based on Omarchy script: firewall
# ======================================================================================

echo "🔎 Verifying kernel status..."
local running_kernel_raw=$(uname -r)
local running_kernel="${running_kernel_raw/-/'.'}"
# This finds the version of the currently installed kernel package (e.g., linux, linux-lts)
# It looks for the package that matches the start of the running kernel's name.
# For example, if uname -r is "6.8.9-lts-1", it will query the "linux-lts" package.
local installed_kernel_pkg_name=$(pacman -Qsq "^linux" | grep -E "^($(uname -r | cut -d'-' -f1-2))" | head -n 1)
# Fallback to 'linux' if the smart detection fails for any reason
if [ -z "${installed_kernel_pkg_name}" ]; then
  echo "⚠️ Could not auto-detect kernel package, falling back to 'linux'."
  installed_kernel_pkg_name="linux"
fi
local installed_kernel=$(pacman -Q "${installed_kernel_pkg_name}" | awk '{print $2}')

echo -e "\e[42m${running_kernel}\e[0m"
echo -e "\e[42m${installed_kernel}\e[0m"

if [ "${running_kernel}" != "${installed_kernel}" ]; then
  echo "============================================================"
  echo "❗️ KERNEL MISMATCH DETECTED"
  echo "   Running kernel:   ${running_kernel}"
  echo "   Installed kernel: ${installed_kernel}"
  echo "   A reboot is required to load the new kernel."
  echo "   Skipping firewall configuration to ensure system stability."
  echo "============================================================"
  return 0
fi

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