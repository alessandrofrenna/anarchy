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

  local AVAILABLE_NIX_PROFILES=$(nix profile list | awk '/^Name:/ {print $2}')

  echo "⏳ Checking essential Nix profile packages (nix-direnv, nixd, nixfmt)..."
  local required_packages=("nix-direnv" "nixd" "nixfmt")
  for pkg in "${required_packages[@]}"; do
    if ! grep -q "${pkg}" <<< "${AVAILABLE_NIX_PROFILES}"; then
      echo "'${pkg}' not found. Installing it now..."
      nix profile install "nixpkgs#${pkg}"
      echo "✅ ${pkg} installed."
    else
      echo "✅ ${pkg} is already installed."
    fi
  done

  echo -e "\n"
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

  local AVAILABLE_EXTENSIONS=$(code --list-extensions)

  echo "⏳ Checking essential VSCode extensions (direnv, nix-ide)..."
  local required_extensions=("mkhl.direnv" "jnoortheen.nix-ide")
  for ext in "${required_extensions[@]}"; do
    if ! grep -q "${ext}" <<< "${AVAILABLE_EXTENSIONS}"; then
      echo "'${ext}' not found. Installing it now..."
      code --install-extension "${ext}" --force
      echo "✅ ${ext} installed."
    else
      echo "✅ ${ext} is already installed."
    fi
  done

  echo -e "\n"
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

  # 2. Create the direnv config file and tell it to use the nix-direnv script
  # that was installed previously via the nix profile.
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