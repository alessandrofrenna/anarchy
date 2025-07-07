# Use dark mode for QT apps too (like kdenlive)
sudo pacman -S --noconfirm kvantum-qt5 gnome-themes-extra # Adds Adwaita-dark theme
yay -S --noconfirm --needed adwaita-qt5-git adwaita-qt6-git

gsettings set org.gnome.desktop.interface gtk-theme "Adwaita-dark"
gsettings set org.gnome.desktop.interface color-scheme "prefer-dark"

# Inter Nerd Font for gtk application
gsettings set org.gnome.desktop.interface font-name "Inter Nerd Font, 10"
gsettings set org.gnome.desktop.interface document-font-name 'Inter Nerd Font 12'
gsettings set org.gnome.desktop.interface monospace-font-name 'JetBrainsMono Nerd Font 10'

# Setup theme links
mkdir -p ~/.config/anarchy/themes
for f in ~/.local/share/anarchy/themes/*; do ln -s "$f" ~/.config/anarchy/themes/; done

# Set initial theme (default to Rose Pine)
mkdir -p ~/.config/anarchy/current
ln -snf ~/.config/anarchy/themes/rosepine ~/.config/anarchy/current/theme
ln -snf ~/.config/anarchy/themes/rosepine/backgrounds ~/.config/anarchy/current/backgrounds
ln -snf ~/.config/anarchy/current/backgrounds/1-Rosepine_Mountains_Default.png ~/.config/anarchy/current/background

# Set specific app links for current theme:
# Hyprlock
ln -snf ~/.config/anarchy/current/theme/hyprlock.conf ~/.config/hypr/hyprlock.conf

# Btop
mkdir -p ~/.config/btop/themes
ln -snf ~/.config/anarchy/current/theme/btop.theme ~/.config/btop/themes/current.theme

# Wofi
ln -snf ~/.config/anarchy/current/theme/wofi.css ~/.config/wofi/style.css

# Mako
mkdir -p ~/.config/mako
ln -snf ~/.config/anarchy/current/theme/mako.ini ~/.config/mako/config