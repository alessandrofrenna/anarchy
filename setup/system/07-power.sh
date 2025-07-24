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
  sudo pacman -S --noconfirm --needed powertop acpi
  echo "✅ Power monitoring tools installed"

  # Enable battery monitoring timer for low battery notifications
  if ! systemctl is-enabled --user --quiet battery-monitor.timer ; then
    echo -e "🔧 Enabling battery-monitor timer..."
    systemctl --user enable --now battery-monitor.timer
    echo -e "✅ battery-monitor timer enabled"
  fi
else
  # This computer runs on power outlet
  echo -e "🖥️  Desktop detected"
  echo -e "⏳ Installing power monitoring..."
  sudo pacman -S --noconfirm --needed powertop
  echo "✅ Power monitoring tools installed"
fi

echo "✅ Power management module setup complete!\n"