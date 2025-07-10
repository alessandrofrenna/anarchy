source "$HOME/.local/share/anarchy/setup/utils/is_installed.sh"

required_packages=(
  "hyprland" "hyprcursor" "hyprshot" "hyprlock" "hypridle" "hyprland-qtutils" "hyprland-qt-support"
  "libdecor" "xdg-desktop-portal-hyprland" "xdg-desktop-portal-gtk" "xorg-xwayland"
  "swaybg" "wofi" "waybar" "mako" "ly" "qt5-wayland" "qt6-wayland"
)

to_install=()
for i in "${!required_packages[@]}"; do
  pkg_name="${required_packages[$i]}"
  check=$(is_installed ${pkg_name})
  if [ $check -eq 1 ]; then
    to_install+=(${pkg_name})
  fi
done

if [[ ${#to_install[@]} -gt 0 ]]; then
  echo -e "Installing Hyprland and Ly..."
  yay -S --noconfirm "${to_install[@]}"
else
  echo -e "Packages already installed, skipping to the next step..."
fi

echo -e "Enabling Ly service..."
sudo systemctl enable ly.service