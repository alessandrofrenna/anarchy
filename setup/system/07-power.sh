#!/bin/bash
set -euo pipefail

# Original references
#   1. https://github.com/basecamp/omarchy/blob/master/install/power.sh
#   2. https://github.com/CyphrRiot/ArchRiot/blob/master/install/system/power.sh
# ======================================================================================
# Based on:
#   1. Omarchy script: power.sh
#   2. ArchRiot script: power.sh
# ======================================================================================

if ls /sys/class/power_supply/BAT* &>/dev/null; then
  # Laptop with battery - install monitoring tools
  echo -e "🔋 Laptop detected"
  echo -e "⏳ Installing power monitoring tools..."
  sudo pacman -S --noconfirm --needed powertop acpi tlp
  echo "✅ Power monitoring tools installed"

  # Enable battery monitoring timer for low battery notifications
  if ! systemctl is-enabled --user --quiet battery-monitor.timer ; then
    echo -e "🔧 Enabling battery-monitor timer..."
    systemctl --user enable --now battery-monitor.timer
    echo -e "✅ battery-monitor timer enabled"
  fi

  # Enable tlp
  if ! sudo systemctl is-enabled --quiet tlp.service ; then
    echo -e "🔧 Enabling TLP service..."
    sudo systemctl enable --now tlp.service
    sudo systemctl mask systemd-rfkill.service systemd-rfkill.socket
    echo -e "✅ TLP service enabled"
  fi
else
  # This computer runs on power outlet
  echo -e "🖥️  Desktop detected"
  echo -e "⏳ Installing power monitoring..."
  sudo pacman -S --noconfirm --needed powertop
  echo "✅ Power monitoring tools installed"
fi

echo "✅ Power management module setup complete!\n"
sleep 3
clear