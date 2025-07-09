# Install microcode
is_installed() {
  if $(pacman -Qi ${1} &>/dev/null); then
    echo 0
    return
  fi
  echo 1
  return
}

packages_to_install=()
cpu_vendor=$(awk -F ': ' '/vendor_id/ {print $2}' /proc/cpuinfo | uniq)
if [ "$cpu_vendor" = "GenuineIntel" ]; then
  packages_to_install=(
    "intel-ucode"
    "linux-firmware-intel"
  )
elif [ "$cpu_vendor" = "AuthenticAMD" ]; then
  packages_to_install=(
    "amd-ucode"
  )
fi

for i in "${!packages_to_install[@]}"; do
  pkg_name="${packages_to_install[$i]}"
  check=$(is_installed ${pkg_name})
  if [ $check -eq 1 ]; then
    echo -e "\nPackage ${pkg_name} is missing, it will be installed"
  else
    echo -e "\nPackage ${pkg_name} is installed"
  fi
done

# Install base devel, needed and useful packages
sudo pacman -S --noconfirm --needed base-devel xdg-utils xdg-user-dirs pacman-contrib dbus dbus-broker-units nano plocate

# Install yay as AUR helper if missing
if ! command -v yay &>/dev/null; then
  cd /tmp
  git clone https://aur.archlinux.org/yay-bin.git
  cd yay-bin
  makepkg -si --noconfirm
  cd -
  rm -rf yay-bin
  cd ~
fi

# Install system-wide packages
yay -S --noconfirm --needed \
  openssh wget curl git avahi \
  udisks2 udiskie unzip unrar p7zip \
  man tldr less whois alacritty \
  fd fzf ripgrep bat imagemagick \
  iwd impala lazygit btop nvtop \
  bash bash-completion ntfs-3g \
  zathura zathura-pdf-mupdf zathura-cb zathura-djvu \
  dosfstools jq yt-dlp mkinitcpio-firmware nwg-look \
  gvfs xorg-xhost gparted

# Enable system-wide services
sudo systemctl enable --now avahi-daemon.service
sudo systemctl enable --now sshd.service
sudo systemctl enable --now udisks2.service

# Copy over Anarchy configs
cp -R ~/.local/share/anarchy/config/* ~/.config/

# Ensure application directory exists for update-desktop-database
mkdir -p ~/.local/share/applications

# Use default bashrc from Anarchy
echo "source ~/.local/share/anarchy/default/bash/rc" > ~/.bashrc

# Create xdg folders inside user /home directory
xdg-user-dirs-update

# Configure udiskie polkit permission for wheel group
echo -e "\nConfiguring udiskie polkit permissions for user in wheel group"

# Remove the old file
sudo rm /etc/polkit-1/rules.d/50-udiskie.rules
# Create the new permissions file
sudo touch /etc/polkit-1/rules.d/50-udiskie.rules
sudo bash -c 'cat >> /etc/polkit-1/rules.d/50-udiskie.rules << 'EOF'
polkit.addRule(function(action, subject) {
  var YES = polkit.Result.YES;
  var permission = {
    // required for udisks1:
    "org.freedesktop.udisks.filesystem-mount": YES,
    "org.freedesktop.udisks.luks-unlock": YES,
    "org.freedesktop.udisks.drive-eject": YES,
    "org.freedesktop.udisks.drive-detach": YES,
    // required for udisks2:
    "org.freedesktop.udisks2.filesystem-mount": YES,
    "org.freedesktop.udisks2.encrypted-unlock": YES,
    "org.freedesktop.udisks2.eject-media": YES,
    "org.freedesktop.udisks2.power-off-drive": YES,
    // required for udisks2 if using udiskie from another seat (e.g. systemd):
    "org.freedesktop.udisks2.filesystem-mount-other-seat": YES,
    "org.freedesktop.udisks2.filesystem-unmount-others": YES,
    "org.freedesktop.udisks2.encrypted-unlock-other-seat": YES,
    "org.freedesktop.udisks2.encrypted-unlock-system": YES,
    "org.freedesktop.udisks2.eject-media-other-seat": YES,
    "org.freedesktop.udisks2.power-off-drive-other-seat": YES
  };
  if (subject.isInGroup("wheel")) {
    return permission[action.id];
  }
});
EOF'
# Set the correct permission to the file
sudo chmod 644 /etc/polkit-1/rules.d/50-udiskie.rules