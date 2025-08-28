#!/bin/bash
set -euo pipefail

# Original reference https://github.com/CyphrRiot/ArchRiot/blob/127baf8204501bede83798b7a4b1d107865ae6fd/install/desktop/fonts.sh#L24
# ======================================================================================
# Based on ArchRiot finalize_font function
# ======================================================================================
# Refresh cache and validate
finalize_fonts() {
    echo "🔄 Finalizing font installation..."

    if ! command -v fc-cache >/dev/null; then
        echo "⚠️ fc-cache command not found. Skipping cache refresh."
        return
    fi
    
    # Refresh font caches. The -v flag provides verbose output.
    # The -r flag removes old caches and creates new ones.
    echo "🔄 Refreshing font caches..."
    fc-cache -vr

    # Force reload for current session
    hash -r 2>/dev/null || true

    echo "✅ Font cache refresh complete."
}

packages=(
  "noto-fonts"
  "noto-fonts-emoji"
  "noto-fonts-cjk"
  "noto-fonts-extra"
  "ttf-nerd-fonts-symbols"
  "ttf-nerd-fonts-symbols-mono"
  "ttf-terminus-nerd"
  "ttf-liberation"
  "ttf-jetbrains-mono-nerd"
  "ttf-firacode-nerd"
  "ttf-cascadia-mono-nerd"
  "ttf-ia-writer"
  "woff2-font-awesome"
  "nerd-fonts-inter"
  "ttf-noto-nerd"
)

echo -e "⏳ Installing font packages..."
for font in "${packages[@]}"; do
  if yay -Q "${font}" &>/dev/null; then
    echo echo -e "${font} already installed, skipping..."
    continue
  fi
  yay -S --noconfirm --needed "${font}"
done
echo -e "✅ Font packages installed\n"

finalize_fonts

sleep 3
clear