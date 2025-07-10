source "$HOME/.local/share/anarchy/setup/utils/is_installed.sh"

required_packages=(
  "linux-firmware" "mesa" "mesa-utils" "libva-utils" "vulkan-icd-loader" "vulkan-mesa-layers" "vulkan-tools" "vdpauinfo"
  "dbus" "base-devel" "pacman-contrib" "openssh" "curl" "stow" "just" "git" "nano"
  "plocate" "xdg-utils" "xdg-user-dirs" "whois" "iwd" "bash" "bash-completion"
  "avahi" "unzip" "unrar" "p7zip" "udisks2" "udiskie" "dosfstools" "exfatprogs"
  "ntfs-3g" "file-roller" "gvfs" "gvfs-mtp" "gvfs-afc" "gvfs-gphoto2" "fuse2"
  "fuse3" "sshfs" "fuseiso" "xorg-xhost" "gparted" "nvtop" "btop" "bat" "man"
  "tldr" "less" "alacritty" "tldr" "less" "alacritty" "nss-mdns" 
  "bluez" "bluez-utils" "bluez-obex" "ripgrep" "webp-pixbuf-loader"
  "imagemagick" "libwebp" "libheif" "libsecret" "libgnome-keyring"
)

# Find the architecture microcode to install
cpu_vendor=$(awk -F ': ' '/vendor_id/ {print $2}' /proc/cpuinfo | uniq)
if [ "$cpu_vendor" = "GenuineIntel" ]; then
  required_packages+=("intel-ucode")
elif [ "$cpu_vendor" = "AuthenticAMD" ]; then
  required_packages+=("amd-ucode")
fi

# Find the integrated GPU drivers to install
libva_env_var=""
igpu_mkinitcpio_module_name=""
if lspci | grep "VGA" | grep "Intel" > /dev/null; then
    echo -e "Found Intel integrated video card\n"
    required_packages+=("vulkan-intel" "intel-media-driver" "intel-gpu-tools" "intel-media-sdk" "libvpl")
    libva_env_var="LIBVA_DRIVER_NAME=iHD"
    igpu_mkinitcpio_module_name="i915"
elif lspci | grep "VGA" | grep "AMD" > /dev/null; then
    echo -e "Found AMD integrated video card\n"
    required_packages+=("vulkan-radeon" "libva-mesa-driver" "radeontop mesa-vdpau")
    libva_env_var="LIBVA_DRIVER_NAME=radeonsi"
    igpu_mkinitcpio_module_name="amdgpu"
fi

to_install=()
for i in "${!required_packages[@]}"; do
  pkg_name="${required_packages[$i]}"
  check=$(is_installed ${pkg_name})
  if [ $check -eq 1 ]; then
    to_install+=(${pkg_name})
  fi
done

echo -e "\nInstalling packages..."
if [[ ${#to_install[@]} -gt 0 ]]; then
  sudo pacman -S --noconfirm --needed "${to_install[@]}"
fi

echo -e "\nEnabling system-wide services..."
sudo systemctl enable --now avahi-daemon.service sshd.service bluetooth.service udisks2.service

echo -e "\nUpdating xdg user directories"
xdg-user-dirs-update

# Ensure application directory exists for update-desktop-database
mkdir -p $HOME/.local/share/applications

# Configure graphics driver environment variables
if ! grep -q ${libva_env_var} /etc/environment; then
  echo "Setting up environment variable: ${libva_env_var}"
  echo "${libva_env_var}" | sudo tee -a /etc/environment
fi

if lspci | grep "VGA" | grep "AMD" > /dev/null; then
    vulkan_env="AMD_VULKAN_ICD=RADV"
    if ! grep -q ${vulkan_env} /etc/environment; then
      echo ${vulkan_env} | sudo tee -a /etc/environment
    fi

    vdpau_driver="VDPAU_DRIVER=radeonsi"
    if ! grep -q ${vdpau_driver} /etc/environment; then
      echo ${vdpau_driver} | sudo tee -a /etc/environment
    fi
fi

# Use stow to sync configurations
if [ ! -d "${HOME}/.config" ]; then
echo "\nDirectory $HOME/.config not found. Creating it..."
  mkdir "$HOME/.config"
fi
stow -v -d ~/.local/share/anarchy -t ~/.config -R config

# Use default bashrc from Anarchy
echo "source ~/.local/share/anarchy/default/bash/rc" >~/.bashrc