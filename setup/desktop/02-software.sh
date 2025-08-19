#!/bin/bash
set -euo pipefail

tools=(
  "pacman-contrib"
  "mkinitcpio-firmware"
  # Codecs
  "gst-plugins-base"
  "gst-plugins-good"
  "gst-plugins-bad"
  "gst-plugins-ugly"
  "gst-plugin-pipewire"
  "gst-plugin-va"
  "flac"
  "faac"
  "wavpack"
  "x264"
  "x265"
  "libvpx"
  "libmpeg2"
  "xvidcore"
  "dav1d"
  "libavif"
  "alac-git"
  # Image libraries
  "libwebp"
  "libheif"
  # Archive
  "unzip"
  "unrar"
  "7zip"
  # Input framework
  "fcitx5"
  "fcitx5-gtk"
  "fcitx5-qt"
  # Wayland related
  "qt5-wayland"
  "qt6-wayland"
  "libdecor"
  # X-Server related
  "xorg-xhost"
  # System tools
  "bash" 
  "bash-completion"
  "alacritty"
  "bat"
  "jq"
  "fd"
  "fzf"
  "eza"
  "tldr"
  "ripgrep"
  "curl"
  "wget"
  "nano"
  "just"
  "plocate"
  "xdg-utils"
  "imagemagick"
  "tree"
  "libqalculate"
  "less"
)

echo -e "⏳ Installing tools..."
yay -S --noconfirm --needed "${tools[@]}"
echo -e "✅ Tools installed"

packages=(
  # Players
  "mpv"
  "decibels"
  # Images
  "loupe"
  # Documents
  "zathura"
  "zathura-pdf-mupdf"
  "zathura-cb"
  "zathura-djvu"
  # Browser
  "firefox"
  "chromium"
  # File
  "nautilus"
  "ffmpegthumbnailer"
  "sushi"
  # Archive
  "file-roller"
  # Clipboard
  "clipse-bin"
  # Password manager
  "bitwarden-bin"
  # Others
  "fragments"
  "gparted"
  "qalculate-gtk"
  "nwg-look"
  "ffmpeg"
  "yt-dlp"
  #TUIs
  "btop"
  "nvtop"
  "impala"
  "bluetui"
  "wiremix"
  "lazygit"
)

echo -e "⏳ Installing software packages..."
yay -S --noconfirm --needed "${packages[@]}"
yay -S --noconfirm --needed spotify || echo -e "❌ Failed to install Spotify. Continuing without!"
echo -e "✅ Software packages installed"

# Refresh application desktop files
"${HOME}/.local/share/anarchy/bin/refresh-application"

echo "📄 Configuring default applications for file types..."

set_default_application() {
  local -n mimetypes=$1
  local application=$2

  for mimetype in "${mimetypes[@]}"; do
    xdg-mime default "${application}" "${mimetype}"
  done
}

# Images
image_mimes=(
  "image/png"
  "image/jpeg"
  "image/gif"
  "image/webp"
  "image/bmp"
  "image/tiff"
  "image/svg+xml"
)
set_default_application image_mimes "org.gnome.Loupe.desktop"

# Videos
video_mimes=(
  "video/mp4"
  "video/x-msvideo"
  "video/x-matroska"
  "video/x-flv"
  "video/x-ms-wmv"
  "video/mpeg"
  "video/ogg"
  "video/webm"
  "video/quicktime"
  "video/3gpp"
  "video/3gpp2"
  "video/x-ms-asf"
  "video/x-ogm+ogg"
  "video/x-theora+ogg"
  "application/ogg"
)
set_default_application video_mimes "mpv.desktop"

# Documents
document_mimes=(
  "application/pdf"
  "application/x-cbr"
  "application/x-cbz"
  "application/x-cb7"
  "application/x-cbt"
  "application/epub+zip"
  "application/x-fictionbook"
  "application/x-mobipocket-ebook"
  "application/image/tiff-fx"
  "application/oxps"
  "image/x-bmp"
  "image/vnd.djvu"
  "image/vnd.djvu+multipage"
)
set_default_application document_mimes "org.pwmt.zathura.desktop"

# Http
http_mimes=(
  "x-scheme-handler/http"
  "x-scheme-handler/https"
)
set_default_application http_mimes "firefox.desktop"

# Set default browser
xdg-settings set default-web-browser firefox.desktop

echo -e "✅ Default applications configured"

echo -e "🗃️ Updating xdg user directories"
xdg-user-dirs-update
xdg-user-dirs-gtk-update
echo -e "✅ xdg user directories updated\n"
sleep 3
clear