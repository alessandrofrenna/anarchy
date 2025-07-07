yay -S --noconfirm --needed \
  ly xorg-xwayland xdg-desktop-portal-hyprland xdg-desktop-portal-gtk qt5ct \
  qt5-wayland qt6-wayland libdecor hyprpolkitagent gnome-keyring \
  hyprland hyprcursor hyprland-qt-support hyprland-qtutils hyprshot \
  hyprlock hypridle wofi waybar mako \
  swaybg gnome-keyring libsecret libgnome-keyring qt6ct

sudo systemctl enable ly.service