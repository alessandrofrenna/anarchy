source "$HOME/.local/share/anarchy/setup/utils/is_installed.sh"

# This function creates a configuration file that systemd loads for the user
# session, making the environment variables available globally.
create_environment_conf() {
  local ENV_DIR="$HOME/.local/share/anarchy/config/environment.d"
  local CONF_FILE="$ENV_DIR/60-dedicated-nvidia-gpu-hyprland.conf"

  echo "Creating environment configuration at '$CONF_FILE'..."
  mkdir -p "$ENV_DIR"

  cat >"$CONF_FILE" <<EOF
# ===============================================================
# Environment variables for Hyprland with NVIDIA (Integrated GPU)
# ===============================================================
# This file is loaded by systemd on login.
#
# NOTE: The DRM devices order might need adjustment.
# Verify your card order with: ls -l /dev/dri/by-path
# The Intel/iGPU should be first. This example assumes iGPU is card0.
AQ_DRM_DEVICES=/dev/dri/card1:/dev/dri/card2

# Hw acceleration env variables
VAAPI_MPEG4_ENABLED=true
VDPAU_DRIVER=nvidia

# NVIDIA environment variables
NVD_BACKEND=direct
__EGL_VENDOR_LIBRARY_FILENAMES=/usr/share/glvnd/egl_vendor.d/50_mesa.json
__GLX_VENDOR_LIBRARY_NAME=mesa
EOF

  echo "Successfully created environment configuration."
}

install_nvidia_dgpu_drivers() {
  if ! lspci | grep -A 2 -E "(VGA|3D)" | grep -i "nvidia"; then
    echo "No NVIDIA Dedicated GPU detected. Exiting..."
    exit 0
  fi
  local gpu_info=$(lspci | grep -i "nvidia")

  local NVIDIA_DRIVER_PACKAGE="nvidia-dkms" # Default to the proprietary driver
  # Turing (16xx, 20xx) and newer can use the open-source modules
  if echo "${gpu_info}" | grep -q -E "RTX [2-9][0-9]|GTX 16"; then
    echo "Detected a Turing or newer GPU, recommending 'nvidia-open-dkms'."
    NVIDIA_DRIVER_PACKAGE="nvidia-open-dkms"
  fi
  echo "Selected driver package: ${NVIDIA_DRIVER_PACKAGE}"

  # Check which kernel is installed and set appropriate headers package
  local KERNEL_HEADERS="linux-headers" # Default
  if pacman -Q linux-zen &>/dev/null; then
    KERNEL_HEADERS="linux-zen-headers"
  elif pacman -Q linux-lts &>/dev/null; then
    KERNEL_HEADERS="linux-lts-headers"
  elif pacman -Q linux-hardened &>/dev/null; then
    KERNEL_HEADERS="linux-hardened-headers"
  fi
  echo "Selected kernel headers: ${KERNEL_HEADERS}"

  # Enable multilib repository for 32-bit libraries
  if ! grep -q "^\s*\[multilib\]" /etc/pacman.conf; then
    echo "Enabling the [multilib] repository..."
    sudo sed -i '/^#\[multilib\]/{s/^#//;n;s/^#//}' /etc/pacman.conf
    echo "Running a system update to refresh repository databases..."
    yay -Syu
  fi
# Install packages
  local required_packages=(
    "${KERNEL_HEADERS}"
    "${NVIDIA_DRIVER_PACKAGE}"
    "nvidia-utils"
    "lib32-nvidia-utils"
    "egl-wayland"
    "libva-nvidia-driver"
  )

  local to_install=()
  for pkg_name in "${required_packages[@]}"; do
    if ! is_installed "${pkg_name}"; then
      to_install+=("${pkg_name}")
    fi
  done

  if [[ ${#to_install[@]} -gt 0 ]]; then
    echo -e "Installing Nvidia driver packages..."
    yay -S --noconfirm "${to_install[@]}"
  else
    echo -e "Packages already installed, skipping to the next step..."
  fi

  # Configure modprobe for early KMS
  echo "Configuring modprobe for early KMS..."
  echo "options nvidia_drm modeset=1" | sudo tee /etc/modprobe.d/nvidia.conf >/dev/null

  # --- Create Environment File ---
  create_environment_conf

  echo -e "\n--- NVIDIA Driver Installation Complete! ---\n"
  echo "An environment file has been created at ~/.config/environment.d/"
  echo "IMPORTANT: You must REBOOT or RE-LOGIN for all changes to take effect."
}

set -e
install_nvidia_dgpu_drivers