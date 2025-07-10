source "$HOME/.local/share/anarchy/setup/utils/is_installed.sh"

required_packages=(
  "gnome-themes-extra" "qqc2-desktop-style" "kvantum"
  "kvantum-theme-libadwaita-git" "morewaita-icon-theme" 
)

to_install=()
for i in "${!required_packages[@]}"; do
  pkg_name="${required_packages[$i]}"
  check=$(is_installed ${pkg_name})
  if [ $check -eq 1 ]; then
    to_install+=(${pkg_name})
  fi
done

if [[ ${#to_install[@]} -gt 0 ]]; then
   eval "$(yay -S --noconfirm --needed ${to_install[@]})"
fi

echo -e "\nSetting Adwaita-dark as theme..."
gsettings set org.gnome.desktop.interface gtk-theme "Adwaita-dark"
gsettings set org.gnome.desktop.interface color-scheme "prefer-dark"
gsettings set org.gnome.desktop.interface cursor-theme 'default'

echo -e "\nSetting Inter Nerd Font for gtk application..."
gsettings set org.gnome.desktop.interface font-name "Inter Nerd Font, 10"
gsettings set org.gnome.desktop.interface document-font-name 'Inter Nerd Font 12'
gsettings set org.gnome.desktop.interface monospace-font-name 'JetBrainsMono Nerd Font 10'

# Setup theme links
stow -v -d ~/.local/share/anarchy/themes -t ~/.local/share/anarchy/config/current_theme -R rosepine

# Default background
ln -snf ~/.local/share/anarchy/themes/rosepine/backgrounds/1-Rosepine_Mountains_Default.png ~/.local/share/anarchy/config/current_theme/current_background

# Mako
mkdir -p ~/.local/share/anarchy/config/mako/config
ln -snf ~/.local/share/anarchy/config/current_theme/mako.ini ~/.local/share/anarchy/config/mako/config

# Btop
mkdir -p ~/.local/share/anarchy/config/btop/themes
ln -snf ~/.local/share/anarchy/config/current_theme/btop.theme ~/.local/share/anarchy/config/btop/themes/current.theme

# Launch again stow on config to sync current_theme
stow -v -d ~/.local/share/anarchy -t ~/.config -R config