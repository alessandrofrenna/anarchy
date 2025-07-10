source "$HOME/.local/share/anarchy/setup/utils/is_installed.sh"

required_packages=(
  "pipewire-audio" "pipewire-pulse" "pipewire-alsa" "pipewire-zeroconf" "wireplumber" "sof-firmware"
  "gst-plugins-base" "gst-plugins-good" "gst-plugins-bad" "gst-plugin-ugly" "gst-plugin-pipewire" "gst-plugin-va"
  "flac" "faac" "alac-git" "wavpack" "faac" "libavif" "dav1d" "x265" "xvidcore" "x264" "libvpx" "libmpeg2"
  "ffmpeg" "playerctl" "pavucontrol" "mpv"  "spotify"
)

to_install=()
for i in "${!required_packages[@]}"; do
  pkg_name="${required_packages[$i]}"
  check=$(is_installed ${pkg_name})
  if [ $check -eq 1 ]; then
    to_install+=(${pkg_name})
  fi
done

echo -e "\nInstalling multimedia sofwares and codecs..."
if [[ ${#to_install[@]} -gt 0 ]]; then
  yay -S --noconfirm "${to_install[@]}"
fi
echo -e "\nEnabling pipewire related services..."
systemctl --user enable --now pipewire.socket pipewire-pulse.socket wireplumber.service
systemctl --user enable --now pipewire.service