#!/bin/bash
set -euo pipefail

make_swap_file() {
  local swap_size=$(free | awk '/Mem/ {x=$2/1024/1024; printf "%.0fG", (x<2 ? 2*x : x<8 ? 1.5*x : x) }')
  echo -e "💾 Creating a ${swap_size} swapfile..."
  sudo fallocate -l "${swap_size}" /swapfile
  sudo chmod 600 /swapfile
  sudo mkswap /swapfile

  # Make the swap permanent after reboot
  if ! grep -qE "^\s*/swapfile\s" /etc/fstab; then
    echo '/swapfile none swap sw 0 0' | sudo tee -a /etc/fstab >/dev/null
    echo -e "✅ swapfile created and added to /etc/fstab"
  else
    echo -e "✅ swapfile created, a fstab entry already exists."
  fi
}

start_swap() {
  echo -e "⏳ Activating swap..."
  sudo swapon /swapfile
  echo -e "✅ Swap activated"
}

if [ ! -f "/swapfile" ]; then
  echo -e "💾 No /swapfile found"
  make_swap_file
  start_swap
  echo -e "✅ /swapfile created and swap activated successfully"
else
  echo -e "💾 /swapfile already exists. Ensuring swap is active..."
  # If the file exists but swap isn't on, turn it on.
  if ! swapon --show | grep -q '/swapfile'; then
    start_swap
  else
    echo -e "✅ Swap is already active."
  fi
fi

echo -e "✅ Swapfile module setup complete!\n"