#!/bin/bash
set -euo pipefail

is_system_drive_encrypted() {
  lsblk -sno TYPE "${1}" | grep -q "crypto_LUKS"
}

is_system_drive_rotational() {
  lsblk -d -n -o ROTA "${1}"
}

is_trim_supported() {
  # Use lsblk to get discard values in bytes
  local lsblk_output=$(lsblk --discard --bytes -n -o DISC-GRAN,DISC-MAX "${1}")
  
  if [[ -z "$lsblk_output" ]]; then
    return 1 # Failure
  fi

  local disc_gran disc_max
  read -r disc_gran disc_max <<< "$lsblk_output"

  # Return 0 (true) only if both values are greater than zero
  if [[ "${disc_gran}" -gt 0 && "${disc_max}" -gt 0 ]]; then
    return 0 # Success
  else
    return 1 # Failure
  fi
}

enable_fstrim() {
  if ! systemctl is-enabled --quiet fstrim.timer; then
    echo "🚀 Enabling and starting fstrim.timer..."
    sudo systemctl enable --now fstrim.timer
    echo -e "✅ fstrim.timer successfully enabled"
  else
    echo -e "✅ fstrim.timer is already enabled"
  fi
}

readonly installation_drive=$(findmnt -n -o SOURCE /)
if is_system_drive_encrypted "${installation_drive}"; then
  echo "🔒 LUKS encryption detected on installation drive, fstrim not needed"
else
  readonly is_rotational=$(is_system_drive_rotational "${installation_drive}")
  if [ "${is_rotational}" -eq 1 ]; then
    echo "💿 Filesystem is on a rotational disk (HDD), fstrim is not applicable."
  elif is_trim_supported "${installation_drive}"; then
    enable_fstrim
  else
    echo "❌ TRIM/discard is not supported by ${installation_drive}."
  fi
fi

sleep 3
clear