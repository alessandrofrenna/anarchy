# Install microcode
cpu_vendor=$(awk -F ': ' '/vendor_id/ {print $2}' /proc/cpuinfo | uniq)
[ "$cpu_vendor" = "GenuineIntel" ] && sudo pacman -S --noconfirm intel-ucode linux-firmware-intel
[ "$cpu_vendor" = "AuthenticAMD" ] && sudo pacman -S --noconfirm amd-ucode

# Install base devel packages
sudo pacman -S --noconfirm --needed base-devel xdg-utils xdg-user-dirs pacman-contrib dbus dbus-broker-units nano

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
  dosfstools jq yt-dlp mkinitcpio-firmware nwg-look

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
echo "source ~/.local/share/anarchy/default/bash/inputrc" > ~/.inputrc

# Create xdg folders inside user /home directory
xdg-user-dirs-update