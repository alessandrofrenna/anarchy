source "$HOME/.local/share/anarchy/setup/utils/is_installed.sh"

required_packages=(
  "mkinitcpio-firmware" "gnome-keyring" "polkit-gnome"
  "brightnessctl" "imv"
  "fcitx5" "fcitx5-gtk" "fcitx5-qt" "fcitx5-configtool"
  "nautilus" "ffmpegthumbnailer" "sushi"
  "firefox" "chromium" "bitwarden-bin"
  "zathura" "zathura-pdf-mupdf" "zathura-cb zathura-djvu" "qalculate-gtk" "nwg-look"
  "yt-dlp" "jq" "lazygit" "impala" "bluetui" "gnome-firmware"
)

to_install=()
for pkg_name in "${required_packages[@]}"; do
  if ! is_installed "${pkg_name}"; then
    to_install+=("${pkg_name}")
  fi
done

if [[ ${#to_install[@]} -gt 0 ]]; then
  echo -e "Installing chosen software..."
  yay -S --noconfirm "${to_install[@]}"
else
  echo -e "Packages already installed, skipping to the next step..."
fi