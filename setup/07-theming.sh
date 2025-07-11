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
  echo -e "Installing cosmetic packages..."
  yay -S --noconfirm "${to_install[@]}"
else
  echo -e "Packages already installed, skipping to the next step..."
fi

echo -e "Setting Adwaita-dark as theme..."
gsettings set org.gnome.desktop.interface gtk-theme "Adwaita-dark"
gsettings set org.gnome.desktop.interface color-scheme "prefer-dark"
gsettings set org.gnome.desktop.interface cursor-theme 'default'

echo -e "Setting Inter Nerd Font for gtk application..."
gsettings set org.gnome.desktop.interface font-name "Inter Nerd Font, 10"
gsettings set org.gnome.desktop.interface document-font-name 'Inter Nerd Font 12'
gsettings set org.gnome.desktop.interface monospace-font-name 'JetBrainsMono Nerd Font 10'


DEFAULT_THEME_NAME="rosepine"
DEFAULT_THEME_WALLPAPER="1-Rosepine_Mountains_Default.png"
THEMES_DIR="${HOME}/.local/share/anarchy/themes"
CURRENT_THEME_DIR="${HOME}/.local/share/anarchy/config/current_theme"
echo ${DEFAULT_THEME_NAME} > "${THEMES_DIR}/.current_theme"

echo -e "Setting current theme to ${DEFAULT_THEME_NAME}"

# Setup theme links
stow -v -d ${THEMES_DIR} -t ${CURRENT_THEME_DIR} -R ${DEFAULT_THEME_NAME}

# Default background
ln -snf "${HOME}/.local/share/anarchy/themes/rosepine/backgrounds/${DEFAULT_THEME_WALLPAPER}" "${CURRENT_THEME_DIR}/current_background"

# Mako
mkdir -p ~/.local/share/anarchy/config/mako/config
ln -snf "${CURRENT_THEME_DIR}/mako.ini" ~/.local/share/anarchy/config/mako/config

# Btop
mkdir -p ~/.local/share/anarchy/config/btop/themes
ln -snf "${CURRENT_THEME_DIR}/btop.theme" ~/.local/share/anarchy/config/btop/themes/current.theme

# Launch again stow on config to sync current_theme
stow -v -d ~/.local/share/anarchy -t ~/.config -R config