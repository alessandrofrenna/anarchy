yay -S --noconfirm --needed \
  ly xorg-xwayland xdg-desktop-portal-hyprland xdg-desktop-portal-gtk qt5ct \
  qt5-wayland qt6-wayland libdecor hyprpolkitagent gnome-keyring \
  hyprland hyprcursor hyprland-qt-support hyprland-qtutils hyprshot \
  hyprlock hypridle wofi waybar mako \
  swaybg gnome-keyring libsecret libgnome-keyring qt6ct

sudo systemctl enable ly.service

# GNOME keyring configuration
sudo bash -c 'cat >> /etc/pam.d/passwd << 'EOF'
password        optional        pam_gnome_keyring.so
EOF'

sudo bash -c 'cat >> /etc/pam.d/login << 'EOF'
auth       optional     pam_gnome_keyring.so
session    optional     pam_gnome_keyring.so auto_start
EOF'