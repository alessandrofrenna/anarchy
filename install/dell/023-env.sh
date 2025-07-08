HYPRLAND_CONF="$HOME/.config/hypr/hyprland.conf"
if [ -f "$HYPRLAND_CONF" ]; then
  cat >>"$HYPRLAND_CONF" <<'EOF'

# Use the internal Intel card to run Hyprland
env = AQ_DRM_DEVICES,/dev/dri/card1:/dev/dri/card2

# Hw acceleration env variables
env = LIBVA_DRIVER_NAME,iHD
env = VAAPI_MPEG4_ENABLED,true
env = VDPAU_DRIVER,nvidia

# NVIDIA environment variables
env = NVD_BACKEND,direct

env = __EGL_VENDOR_LIBRARY_FILENAMES,/usr/share/glvnd/egl_vendor.d/50_mesa.json
env = __GLX_VENDOR_LIBRARY_NAME,mesa

# If you want to offload intensive video resource application to the Nvidia card,
# launch the application with these env variables:
# __GLX_VENDOR_LIBRARY_NAME="nvidia" __NV_PRIME_RENDER_OFFLOAD=1 __VK_LAYER_NV_optimus="NVIDIA_only"
EOF

fi