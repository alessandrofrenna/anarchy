#!/bin/bash
set -euo pipefail

install_direnv() {
  echo "⏳ Installing direnv..."
  sudo pacman -S --noconfirm --needed direnv
  echo -e "✅ direnv installed.\n "
}

install_nix() {
  # Installs the entire Nix package manager, including nix-shell, nix develop, etc.
  echo "⏳ Installing Nix..."
  # Check if Nix is already installed by looking for the nix command
  if command -v nix &> /dev/null; then
    echo -e  "✅ Nix is already installed. Skipping.\n"
  else
    curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install --no-confirm
    # Source the new profile to make 'nix' available to this script session
    . /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh
    echo -e "✅ Nix installed.\n"
  fi
}

install_vscode()
{
  if command -v yay &> /dev/null; then
    echo "⏳ Installing vscode..."
    yay -S --noconfirm --needed visual-studio-code-bin
    echo -e "✅ vscode installed.\n"
  else
    echo -e "❌ yay AUR helper is missing. Skipping vscode installation.\n"
  fi
}

configure_nix_direnv() {
  echo "⏳ Configuring direnv to use Nix..."
  
  # 1. Hook direnv into the user's bash shell if missing
  # This makes direnv active in the terminal

  local RC_FILE="${HOME}/.bashrc"

  if ! grep -q "direnv hook bash" "${RC_FILE}"; then
    tee -a "${RC_FILE}" >/dev/null <<'EOF'

# Hook for direnv
if command -v direnv &> /dev/null; then
  eval "$(direnv hook bash)"
fi
EOF

  fi

  # 2. Install nix-direnv using the Nix profile
  # This is the modern, recommended way.
  nix profile add nixpkgs#nix-direnv

  # 3. Create the direnv config file and tell it to use the nix-direnv script
  # that was just installed via the nix profile.
  local DIR_ENV_CFG="${HOME}/.config/direnv"
  mkdir -p "${DIR_ENV_CFG}"
  tee "${DIR_ENV_CFG}/direnvrc" >/dev/null <<'EOF'
# Use the nix-direnv integration installed via our Nix profile
source "$HOME/.nix-profile/share/nix-direnv/direnvrc"
EOF

  echo -e "✅ direnv configured for Nix.\n"
}

echo -e "\033c🚀 Starting Dev Env Setup...\n"
install_direnv
install_nix
install_vscode
configure_nix_direnv

echo -e "\033c✅ Nix setup completed. Restart the terminal session to apply change!\n"
sleep 2
exit 0