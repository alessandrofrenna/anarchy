#!/bin/bash
set -euo pipefail

UWSM_ENV_FILE="$HOME/.config/uwsm/env"
# Create env file if it is missing
if [ ! -f "$UWSM_ENV_FILE" ]; then
  touch "$UWSM_ENV_FILE"
fi

# Function to add a line to .profile if it doesn't already exist
add_to_env() {
  # grep -q: quiet mode, -x: match whole line, -F: treat pattern as fixed string
  if ! grep -qFx "$1" "$UWSM_ENV_FILE"; then
    echo "$1" >> "$UWSM_ENV_FILE"
  fi
}

# List of packages to install after
required_packages=(
  "linux-firmware"
  "linux-headers"
  "fwupd"
  "libva-utils"
  "vdpauinfo"
  "vulkan-tools"
  "vulkan-icd-loader"
  "bolt"
)

# Find the architecture microcode to install
cpu_vendor=$(awk -F ': ' '/vendor_id/ {print $2}' /proc/cpuinfo | uniq)
if [ "$cpu_vendor" = "GenuineIntel" ]; then
  echo -e "💻 Found GenuineIntel CPU"
  required_packages+=("intel-ucode")
elif [ "$cpu_vendor" = "AuthenticAMD" ]; then
  echo -e "💻 Found AuthenticAMD CPU"
  required_packages+=("amd-ucode")
fi

# Find the integrated GPU drivers to install
libva_env_var=""
vdpau_env_var=""
vulkan_env_var=""
if lspci | grep "VGA" | grep "Intel" > /dev/null; then
  echo -e "🎥 Found Intel integrated GPU"
  required_packages+=(
    "mesa"
    "lib32-mesa"
    "vulkan-intel"
    "lib32-vulkan-intel"
    "intel-media-driver"
    "libva-intel-driver"
    "intel-gmmlib"
    "libvpl" 
    "intel-media-sdk"
    "libvdpau-va-gl"
    "mesa-utils"
  )
  libva_env_var="LIBVA_DRIVER_NAME=iHD"
  vdpau_env_var="VDPAU_DRIVER=va_gl"
  vulkan_env_var="ANV_DEBUG=video-decode,video-encode"
elif lspci | grep "VGA" | grep "AMD" > /dev/null; then
  echo -e "🎥 Found AMD integrated GPU"
  required_packages+=(
    "mesa"
    "lib32-mesa"
    "vulkan-radeon"
    "lib32-vulkan-radeon"
    "mesa-utils"
  )
  libva_env_var="LIBVA_DRIVER_NAME=radeonsi"
  vdpau_env_var="VDPAU_DRIVER=radeonsi"
  vulkan_env_var="RADV_PERFTEST=video_decode,video_encode"
fi

# Check if an NVIDIA GPU is available (it could be either integrated or dedicated)
additional_env=""
if lspci | grep -iE "(VGA|3D)" | grep -i "nvidia" > /dev/null; then
  echo -e "🎥 Found NVIDIA GPU"
  required_packages+=(
    "nvidia-dkms"
    "nvidia-utils"
    "lib32-nvidia-utils"
    "libva-nvidia-driver"
    "egl-wayland"
  )
  vdpau_env_var="VDPAU_DRIVER=nvidia"
  additional_env="NVD_BACKEND=direct"
  
  if [ -z "$libva_env_var" ]; then
    libva_env_var="LIBVA_DRIVER_NAME=nvidia"
    additional_env="$additional_env\n__GLX_VENDOR_LIBRARY_NAME=nvidia"
  else
    additional_env="$additional_env\n__EGL_VENDOR_LIBRARY_FILENAMES=/usr/share/glvnd/egl_vendor.d/50_mesa.json\n__GLX_VENDOR_LIBRARY_NAME=mesa"
  fi

  echo "options nvidia_drm modeset=1" | sudo tee /etc/modprobe.d/nvidia.conf >/dev/null
fi

# Install packages
echo -e "⏳ Installing required packages for hardware module..."
sudo pacman -S --noconfirm --needed "${required_packages[@]}"
echo -e "✅ Hardware module required packages installed"

# Add environment variables to .profile file
echo "🔧 Configuring environment variables in $HOME/.profile..."
if [ -n "$libva_env_var" ]; then add_to_env "export $libva_env_var"; fi
if [ -n "$vdpau_env_var" ]; then add_to_env "export $vdpau_env_var"; fi
if [ -n "$vulkan_env_var" ]; then add_to_env "export $vulkan_env_var"; fi
add_to_env "export VAAPI_MPEG4_ENABLED=true"

if [ -n "$additional_env" ]; then
  # Handle multi-line strings from the NVIDIA section
  while IFS= read -r line; do
    if [ -n "$line" ]; then # Ensure we don't add empty lines
      add_to_env "export $line"
    fi
  done <<< "$additional_env"
fi
echo "✅ Environment variables configured."

# Enable fwupd
echo -e "🔧 Tweaking fwupd settings..."
FWUPD_CONG_FILE="/etc/fwupd/fwupd.conf"
if sudo grep -q -E "^\s*P2pPolicy=nothing\s*$" "${FWUPD_CONG_FILE}"; then
  echo "🔧 Passim already disabled for fwupd"
else
  echo -e "🔧 Disabling passim for fwupd..."
  echo "P2pPolicy=nothing" | sudo tee -a ${FWUPD_CONG_FILE} >/dev/null
  sudo systemctl mask passim.service
  echo -e "🔧 Disabled passim for fwupd"
fi

echo -e "🔧 Enabling fwupd service..."
sudo systemctl enable --now fwupd.service fwupd-refresh.timer
echo -e "✅ Fwupd service enabled"

echo -e "🔧 Enabling bolt service..."
sudo systemctl enable --now bolt
echo -e "✅ Bolt service enabled"

echo -e "⌨️ Fixing Apple and Apple-compatible keyboards FN key"
FILE_PATH="/etc/modprobe.d/hid_apple.conf"
CONFIG_LINE="options hid_apple fnmode=2"
if ! grep -qF -- "${CONFIG_LINE}" "${FILE_PATH}" 2>/dev/null; then
  # Append the line if it doesn't exist
  echo "${CONFIG_LINE}" | sudo tee -a "${FILE_PATH}" >/dev/null
  echo "✅ Apple and Apple-compatible keyboards successfully fixed"
else
  echo "✅ Apple and Apple-compatible keyboards already fixed"
fi

echo -e "✅ Hardware module setup complete!\n"
sleep 3
clear