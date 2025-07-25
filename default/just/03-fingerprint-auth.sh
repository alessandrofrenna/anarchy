#!/bin/bash
set -euo pipefail

readonly RULE_1="auth       [success=1 default=ignore]  pam_succeed_if.so    service in sudo:su:su-l tty in :unknown"
readonly RULE_2="auth       sufficient                  pam_unix.so try_first_pass likeauth nullok"
readonly RULE_3="auth       sufficient                  pam_fprintd.so"

readonly PAM_FILES=(
  "/etc/pam.d/system-local-login"
  "/etc/pam.d/sudo"
  "/etc/pam.d/polkit-1"
)

create_pam_polkit_1_file() {
  # Creates a minimal but valid PAM file that the script can then modify.
  local file_name="/etc/pam.d/polkit-1"
  echo -e "💡 File '${file_name}' not found. Creating it now..."
  sudo tee "${file_name}" >/dev/null <<'EOF'
#%PAM-1.0

account   required pam_unix.so
password  required pam_unix.so
session   required pam_unix.so
EOF
  echo -e "✅ File '${file_name}' created"
}

backup_pam_file() {
  local pam_file=$1
  local bak_file="${pam_file}.bak"
  echo "💡 Configuration change needed. Creating backup..."
  sudo cp "${pam_file}" "${bak_file}"
  echo "✅ Backup file created at: ${bak_file}"
}

remove_old_rules() {
  local pam_file=$1
  # This deletes any line containing the specified modules to prevent duplicates or out-of-order rules.
  # Use this function to remove the module rules completely
  sudo sed -i -E '/^auth.*(pam_fprintd.so|pam_unix.so|pam_succeed_if.so)/d' "${pam_file}"
}

add_rules() {
  local pam_file=$1
  echo -e "🔧 Adding PAM rules to ${pam_file}..."
  sudo sed -i "1i ${RULE_3}" "${pam_file}"
  sudo sed -i "1i ${RULE_2}" "${pam_file}"
  sudo sed -i "1i ${RULE_1}" "${pam_file}"
  echo -e "✅ PAM rules added to ${pam_file}"
}

# Install and enable fingerprint auth
install_fingerprint_required_packages() {
  if ! command -v lsusb; then
    sudo pacman -S --noconfirm --needed usbutils
  fi

  if ! lsusb | grep -Eiq 'fingerprint|synaptics|goodix'; then
    echo -e "\033c🚩 No fingerprint sensor detected"
    exit 1
  fi

  echo -e "\033c⏳ Installing fingerprint required packages..."
  yay -S --noconfirm fprintd
  echo -e "✅ Fingerprint required packages installed"
}

enable_fingerprint_auth() {
  echo -e "☝️ Enabling fingerprint authentication..."
  for pam_file in "${PAM_FILES[@]}"; do
    if [ ! -f "${pam_file}" ]; then
      if [ "${pam_file}" == "/etc/pam.d/polkit-1" ]; then
        create_pam_polkit_1_file
      else
        echo "⚠️ File '${pam_file}' not found, skipping..."
        continue
      fi
    fi

    if ! (grep -qF -- "$RULE_1" "${pam_file}" && \
          grep -qF -- "$RULE_2" "${pam_file}" && \
          grep -qF -- "$RULE_3" "${pam_file}"); then
        backup_pam_file "${pam_file}"
        remove_old_rules "${pam_file}"
        add_rules "${pam_file}"
    else
      echo -e "✅ PAM rules already configured for ${pam_file}. No changes required"
    fi
  done

  echo -e "\033c✅ Fingerprint authentication enabled!"
}

enroll_first_fingerprint() {
  echo -e "☝️ Let's enroll the right index finger as the first fingerprint. Move the finger around on the sensor untill the process completes!"
  sudo fprintd-enroll "${USER}"

  echo -e "☝️ Verifying the enrolled fingerprint..."

  if sudo fprintd-verify; then
    echo -e "✅ Perfect! Now you can use your fingerprint to authenticate"
  else
    echo -e "🚩 Fingerprint enrolling process failed. Something went wrong"
    exit 1
  fi
}

# Disable fingerprint auth and remove packages
remove_enrolled_fingerprints() {
  echo -e "☝️ Removing registered fingerprints for ${USER}..."
  sudo fprintd-delete "${USER}" --all
  echo -e "✅ Removed all the fingerprints registered by ${USER}!"
}

disable_fingerprint_auth() {
  echo -e "☝️ Disabling fingerprint authentication..."
  
  for pam_file in "${PAM_FILES[@]}"; do
    if [ -f "${pam_file}.bak" ]; then
      if [ -f "${pam_file}" ]; then
        sudo rm "${pam_file}"
      fi
      sudo mv "${pam_file}.bak" "${pam_file}"
    elif [ -f "${pam_file}" ]; then
      remove_old_rules "${pam_file}"
    fi
  done

  echo -e "✅ Fingerprint authentication disabled!"
  exit 0
}

remove_fingerprint_installed_packages() {
  echo -e "⏳ Removing fingerprint installed packages..."
  yay -Rns --noconfirm fprintd
  echo -e "✅ Fingerprint packages removed"
}

# Script execution
if [[ "--remove" == "${1-}" ]]; then
  remove_enrolled_fingerprints
  disable_fingerprint_auth
  remove_fingerprint_installed_packages
  
  sleep 2
  echo -e "\033c✅ Fingerprint authentication disable and remove process completed!\n"
  exit 0
fi

install_fingerprint_required_packages
enable_fingerprint_auth
enroll_first_fingerprint

sleep 2
echo -e "\033c✅ Fingerprint authentication setup completed!\n"
exit 0