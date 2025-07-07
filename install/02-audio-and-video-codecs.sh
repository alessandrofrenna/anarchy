# Install multimedia packages
yay -S --noconfirm --needed \
  wireplumber pipewire-pulse pipewire-alsa pipewire-audio \
  pipewire-zeroconf pwvucontrol pamixer \
  gst-plugins-base gst-plugins-good gst-plugin-ugly gst-plugins-bad gst-plugin-va \
  gst-plugin-pipewire ffmpeg flac alac-git wavpack \
  faac libwebp libavif libheif dav1d \
  x265 xvidcore x264 libvpx libmpeg2 \
  libva-utils vdpauinfo vulkan-tools
  
# Enable services
sudo systemctl --user --now enable pipewire pipewire-pulse.service wireplumber