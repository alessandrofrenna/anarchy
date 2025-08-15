#!/bin/bash
set -euo pipefail

# Original reference https://github.com/basecamp/omarchy/blob/dev/install/config/timezones.sh
# ======================================================================================
# Based on Omarchy script: timezone.sh
# ======================================================================================
readonly FILE_PATH="/etc/sudoers.d/anarchy-tzupdate"
if ! command -v tzupdate &>/dev/null; then
  yay -S --noconfirm --needed tzupdate
  sudo tee "${FILE_PATH}" >/dev/null <<EOF
%wheel ALL=(root) NOPASSWD: /usr/bin/tzupdate, /usr/bin/timedatectl
EOF
  sudo chmod 0440 "${FILE_PATH}"
fi

echo -e "✅ Timezone management module setup complete!\n"
sleep 3
clear