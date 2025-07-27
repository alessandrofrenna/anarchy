#!/bin/bash
set -euo pipefail

echo -e "⏳ Installing required packages for bluetooth module..."
sudo pacman -S --noconfirm --needed bluez bluez-utils bluez-obex
echo -e "✅ Bluetooth module required packages installed"

echo -e "🔧 Enabling bluetooth and obex services..."
sudo systemctl enable --now bluetooth.service
systemctl --user enable --now obex.service # enable bluetooth file sharing service
echo -e "✅ Bluetooth and obex services enabled"

BLUETOOTH_CONF="/etc/bluetooth/main.conf"
DESIRED_SETTING="AutoEnable=false"

echo "🔧 Tweaking bluetooth settings in ${BLUETOOTH_CONF}..."
# First, check if the setting is already correct and uncommented
if sudo grep -qE "^\s*${DESIRED_SETTING}\s*$" "$BLUETOOTH_CONF"; then
    echo "🔧 Bluetooth AutoEnable is already set correctly"
else
  sudo sed -i -E 's/^\s*#?\s*AutoEnable=.*/AutoEnable=false/' "$BLUETOOTH_CONF"
  sudo sed -i -E "s/^\s*#?\s*AutoEnable=.*/$DESIRED_SETTING/" "$BLUETOOTH_CONF"
  echo "🔧 Set bluetooth option $DESIRED_SETTING"
fi

echo -e "✅ Bluetooth module setup complete!\n"