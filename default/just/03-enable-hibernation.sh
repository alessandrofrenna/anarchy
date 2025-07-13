add_resume_hook() {
  local MKINITCPIO_CONF="/etc/mkinitcpio.conf"
  echo "Checking for 'resume' hook in ${MKINITCPIO_CONF}..."
  # First, check if the hook is already present in the HOOKS line
  if grep -q -E "^HOOKS=\(.*\bresume\b.*\)" "$MKINITCPIO_CONF"; then
    echo "'resume' hook already present. No changes needed."
  else
    echo "'resume' hook not found. Adding it after 'filesystems'..."
    sudo cp -v "${MKINITCPIO_CONF}" "${MKINITCPIO_CONF}.backup"
    echo "A backup of your old configuration was saved to ${MKINITCPIO_CONF}.backup"
    # If not present, use sed to find 'filesystems' and insert ' resume' after it.
    # The -i flag edits the file directly, and requires sudo.
    sudo sed -i -E '/^HOOKS=\(/ s/(\b(filesystems|fsck)\b)/\1 resume/' "$MKINITCPIO_CONF"
    echo "Successfully added 'resume' hook."
  fi
}

configure_power_settings() {
  local LOGIND_CONF="/etc/systemd/logind.conf"
  local SLEEP_CONF="/etc/systemd/sleep.conf"

  # --- Task 1: Configure HandleLidSwitch ---
  echo "Checking settings in ${LOGIND_CONF}..."
  # Use grep -q to quietly check if the setting is already correct.
  if grep -q -E "^\s*HandleLidSwitch=suspend-then-hibernate\s*$" "$LOGIND_CONF"; then
    echo "HandleLidSwitch is already set to suspend-then-hibernate."
  else
    echo "Setting HandleLidSwitch=suspend-then-hibernate..."
    # Use sed to find the line (commented or not) and replace it.
    sudo sed -i -E 's/^\s*#?\s*HandleLidSwitch=.*/HandleLidSwitch=suspend-then-hibernate/' "$LOGIND_CONF"
  fi

  # --- Task 2: Configure HibernateDelaySec ---
  echo "Checking settings in ${SLEEP_CONF}..."
  if grep -q -E "^\s*HibernateDelaySec=120\s*$" "$SLEEP_CONF"; then
    echo "HibernateDelaySec is already set to 120 seconds."
  else
    echo "Setting HibernateDelaySec=120..."
    sudo sed -i -E 's/^\s*#?\s*HibernateDelaySec=.*/HibernateDelaySec=120/' "$SLEEP_CONF"
  fi

  echo "Done."
}

enable_hibernation() {
  local SWAP_FILE="/swapfile"
  local CMDLINE_DIR="/etc/kernel/cmdline.d"
  local HIBERNATION_CONF_FILE="${CMDLINE_DIR}/hibernate.conf"

  if [ ! -f "${SWAP_FILE}" ]; then
    echo -e "Swap not found at ${SWAP_FILE}, hibernation cannot be enabled!" >&2
    exit 1
  fi

  if [ ! -d "${CMDLINE_DIR}" ]; then
    sudo mkdir -p "${CMDLINE_DIR}"
  fi

  echo "Calculating hibernation parameters..."

  local ROOT_PARTITION="$(findmnt -n -o SOURCE /)"
  local RESUME_OFFSET="$(sudo filefrag -v /swapfile | awk '$1=="0:" {print $4+0; exit}')"
  # local RESUME_OFFSET="$(sudo filefrag -v /swapfile | sed -n '4p' | awk '{print $4+0}')"

  if [ -z "$RESUME_OFFSET" ]; then
      echo "Error: Could not determine resume_offset for $SWAP_FILE." >&2
      exit 1
  fi

  echo "Writing configuration to ${HIBERNATION_CONF_FILE}..."
  echo "resume=${ROOT_PARTITION} resume_offset=${RESUME_OFFSET}" | sudo tee "${HIBERNATION_CONF_FILE}" >/dev/null

  add_resume_hook
  sudo mkinitcpio -P
  configure_power_settings

  echo "Power settings configuration completed. Restarting systemd-logind service to apply changes..."
  sudo systemctl restart systemd-logind.service

  echo "Hibernation configured successfully."
}

set -e

enable_hibernation