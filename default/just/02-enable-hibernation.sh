#!/bin/bash
set -euo pipefail

create_or_update_nvidia_suspend_then_hibernate_service() {
  local SERVICE_FILE="/usr/lib/systemd/system/nvidia-suspend-then-hibernate.service"
  echo "🔧 Configuring ${SERVICE_FILE}..."

  # Create the service file with default content if it doesn't exist.
  if [ ! -f "${SERVICE_FILE}" ]; then
    echo "⏳ Service file not found. Creating it..."
    sudo tee "${SERVICE_FILE}" >/dev/null <<'EOF'
[Unit]
Description=NVIDIA system suspend-then-hibernate actions
Before=systemd-suspend-then-hibernate.service

[Service]
Type=oneshot
ExecStart=/usr/bin/logger -t suspend -s "nvidia-suspend-then-hibernate.service"
ExecStart=/usr/bin/nvidia-sleep.sh "suspend"

[Install]
WantedBy=systemd-suspend-then-hibernate.service
EOF
    echo "✅ Service file created."
  else
    echo "💡 Service file already exists."
  fi

  # Define the old and new lines for replacement.
  local OLD_EXEC='ExecStart=/usr/bin/nvidia-sleep.sh "suspend"'
  local NEW_EXEC='ExecStart=/usr/bin/nvidia-sleep.sh "hibernate"'

  # Check if the file needs to be updated.
  if grep -qF "${OLD_EXEC}" "${SERVICE_FILE}"; then
    echo "⏳ Updating ExecStart to use 'hibernate'..."
    # Use sed to replace the 'suspend' command with 'hibernate'.
    sudo sed -i "s|${OLD_EXEC}|${NEW_EXEC}|" "${SERVICE_FILE}"
    echo "✅ ExecStart successfully updated."
  elif grep -qF "${NEW_EXEC}" "${SERVICE_FILE}"; then
    echo "✅ ExecStart already configured for 'hibernate'. No changes needed."
  else
    echo "⚠️  Could not find the expected ExecStart line to update in ${SERVICE_FILE}."
  fi
}

fix_nvidia_gpu_problems() {
  # Create or update the service file before reloading the daemon.
  create_or_update_nvidia_suspend_then_hibernate_service

  sudo systemctl daemon-reload
  sudo systemctl disable nvidia-resume.service
  sudo systemctl enable nvidia-suspend.service
  sudo systemctl enable nvidia-hibernate.service
  sudo systemctl enable nvidia-suspend-then-hibernate.service
  sudo systemctl enable nvidia-resume.service
}

add_resume_hook() {
  local MKINITCPIO_CONF="/etc/mkinitcpio.conf"
  echo "⏳ Checking for 'resume' hook in ${MKINITCPIO_CONF}..."
  # First, check if the hook is already present in the HOOKS line
  if grep -q -E "^HOOKS=\(.*\bresume\b.*\)" "$MKINITCPIO_CONF"; then
    echo "'✅ resume' hook already present. No changes needed."
  else
    echo "'🔧 resume' hook not found. Adding it after 'filesystems'..."
    sudo cp -v "${MKINITCPIO_CONF}" "${MKINITCPIO_CONF}.backup"
    echo "💡 A backup of your old configuration was saved to ${MKINITCPIO_CONF}.backup"
    # If not present, use sed to find 'filesystems' and insert ' resume' after it.
    # The -i flag edits the file directly, and requires sudo.
    sudo sed -i -E '/^HOOKS=\(/ s/(\b(filesystems|fsck)\b)/\1 resume/' "$MKINITCPIO_CONF"
    echo "✅ Successfully added 'resume' hook"
  fi
}

configure_power_settings() {
  local LOGIN_CONF_DIR="/etc/systemd/logind.conf.d"
  local SUSPEND_THEN_HIBERNATE_FILE="${LOGIN_CONF_DIR}/suspend-then-hibernate.conf"

  if [ ! -d "${LOGIN_CONF_DIR}" ]; then
    sudo mkdir -p "${LOGIN_CONF_DIR}"
  fi

  if [ ! -f "${SUSPEND_THEN_HIBERNATE_FILE}" ]; then
    sudo tee "${SUSPEND_THEN_HIBERNATE_FILE}" >/dev/null <<'EOF'
[Login]
IdleAction=suspend-then-hibernate
IdleActionSec=10min
HandleLidSwitch=suspend-then-hibernate
HandlePowerKey=suspend-then-hibernate
HandlePowerKeyLongPress=poweroff
EOF
  fi

  local SLEEP_CONF_DIR="/etc/systemd/sleep.conf.d"
  local SLEEP_CONF_FILE="${SLEEP_CONF_DIR}/custom-sleep.conf"

  if [ ! -d "${SLEEP_CONF_DIR}" ]; then
    sudo mkdir -p "${SLEEP_CONF_DIR}"
  fi

  if [ ! -f "${SLEEP_CONF_FILE}" ]; then
    sudo tee "${SLEEP_CONF_FILE}" >/dev/null <<'EOF'
[Sleep]
HibernateDelaySec=3min
EOF
  fi

  echo "✅ Power settings configuration completed"
}

enable_hibernation() {
  local SWAP_FILE="/swapfile"
  local CMDLINE_DIR="/etc/kernel/cmdline.d"
  local HIBERNATION_CONF_FILE="${CMDLINE_DIR}/hibernate.conf"

  if [ ! -f "${SWAP_FILE}" ]; then
    echo -e "🚩 Swap not found at ${SWAP_FILE}, hibernation cannot be enabled!" >&2
    exit 1
  fi

  if [ ! -d "${CMDLINE_DIR}" ]; then
    sudo mkdir -p "${CMDLINE_DIR}"
  fi

  echo "⏳ Calculating hibernation parameters..."

  local ROOT_PARTITION="$(findmnt -n -o SOURCE /)"
  local RESUME_OFFSET="$(sudo filefrag -v /swapfile | awk '$1=="0:" {print $4+0; exit}')"

  if [ -z "$RESUME_OFFSET" ]; then
      echo "🚩 Error: Could not determine resume_offset for $SWAP_FILE." >&2
      exit 1
  fi

  echo "🔧 Writing configuration to ${HIBERNATION_CONF_FILE}..."
  echo "resume=${ROOT_PARTITION} resume_offset=${RESUME_OFFSET}" | sudo tee "${HIBERNATION_CONF_FILE}" >/dev/null

  add_resume_hook
  sudo mkinitcpio -P
  clear

  configure_power_settings
  if lspci | grep -iE "(VGA|3D)" | grep -i "nvidia" > /dev/null; then
    fix_nvidia_gpu_problems
  fi

  sleep 2
  echo -e "\033c✅ Hibernation configured successfully."

  sleep 2
  sudo systemctl restart systemd-logind && sudo systemctl reboot
}

enable_hibernation

