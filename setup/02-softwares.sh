source "$HOME/.local/share/anarchy/setup/utils/is_installed.sh"

required_packages=(
  "mkinitcpio-firmware" "gnome-keyring"
  "brightnessctl" "imv"
  "fcitx5" "fcitx5-gtk" "fcitx5-qt" "fcitx5-configtool"
  "nautilus" "nautilus-bluetooth" "ffmpegthumbnailer" "sushi"
  "firefox" "chromium" "bitwarden-bin"
  "zathura" "zathura-pdf-mupdf" "zathura-cb zathura-djvu" "qalculate-gtk" "nwg-look"
  "yt-dlp" "jq" "lazygit" "impala" "bluetui"
)

to_install=()
for i in "${!required_packages[@]}"; do
  pkg_name="${required_packages[$i]}"
  check=$(is_installed ${pkg_name})
  if [ $check -eq 1 ]; then
    to_install+=(${pkg_name})
  fi
done

echo -e "\nInstalling some packages..."
if [[ ${#to_install[@]} -gt 0 ]]; then
  yay -S --noconfirm "${to_install[@]}"
fi