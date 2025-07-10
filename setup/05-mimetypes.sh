update-desktop-database ~/.local/share/applications

# Open all images with imv
xdg-mime default imv.desktop image/png
xdg-mime default imv.desktop image/jpeg
xdg-mime default imv.desktop image/gif
xdg-mime default imv.desktop image/webp
xdg-mime default imv.desktop image/bmp
xdg-mime default imv.desktop image/tiff
xdg-mime default imv.desktop image/webp
xdg-mime default imv.desktop image/svg+xml

# Open PDFs and other format with the Zathura
xdg-mime default org.pwmt.zathura.desktop application/pdf
xdg-mime default org.pwmt.zathura.desktop application/x-cbr
xdg-mime default org.pwmt.zathura.desktop application/x-cbz
xdg-mime default org.pwmt.zathura.desktop application/x-cb7
xdg-mime default org.pwmt.zathura.desktop application/x-cbt
xdg-mime default org.pwmt.zathura.desktop application/epub+zip
xdg-mime default org.pwmt.zathura.desktop application/x-fictionbook
xdg-mime default org.pwmt.zathura.desktop application/x-mobipocket-ebook
xdg-mime default org.pwmt.zathura.desktop application/image/tiff-fx
xdg-mime default org.pwmt.zathura.desktop application/oxps
xdg-mime default org.pwmt.zathura.desktop image/x-bmp
xdg-mime default org.pwmt.zathura.desktop image/vnd.djvu
xdg-mime default org.pwmt.zathura.desktop image/vnd.djvu+multipage

# Use Firefox as the default browser
xdg-settings set default-web-browser firefox.desktop
xdg-mime default firefox.desktop x-scheme-handler/http
xdg-mime default firefox.desktop x-scheme-handler/https

# Open video files with mpv
xdg-mime default mpv.desktop video/mp4
xdg-mime default mpv.desktop video/x-msvideo
xdg-mime default mpv.desktop video/x-matroska
xdg-mime default mpv.desktop video/x-flv
xdg-mime default mpv.desktop video/x-ms-wmv
xdg-mime default mpv.desktop video/mpeg
xdg-mime default mpv.desktop video/ogg
xdg-mime default mpv.desktop video/webm
xdg-mime default mpv.desktop video/quicktime
xdg-mime default mpv.desktop video/3gpp
xdg-mime default mpv.desktop video/3gpp2
xdg-mime default mpv.desktop video/x-ms-asf
xdg-mime default mpv.desktop video/x-ogm+ogg
xdg-mime default mpv.desktop video/x-theora+ogg
xdg-mime default mpv.desktop application/ogg
