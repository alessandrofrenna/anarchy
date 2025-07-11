source "$HOME/.local/share/anarchy/setup/utils/is_installed.sh"

required_packages=(
  "noto-fonts" "noto-fonts-emoji" "noto-fonts-cjk" "noto-fonts-extra"
  "ttf-nerd-fonts-symbols" "ttf-nerd-fonts-symbols-mono" "ttf-terminus-nerd"
  "ttf-jetbrains-mono-nerd" "ttf-firacode-nerd" "ttf-dejavu-nerd" "ttf-roboto-mono-nerd"
  "ttf-noto-nerd" "nerd-fonts-inter"
)

to_install=()
for pkg_name in "${required_packages[@]}"; do
  if ! is_installed "${pkg_name}"; then
    to_install+=("${pkg_name}")
  fi
done

if [[ ${#to_install[@]} -gt 0 ]]; then
  echo -e "Installing fonts..."
  yay -S --noconfirm "${to_install[@]}"
else
  echo -e "Packages already installed, skipping to the next step..."
fi

echo -e "Reloading font cache..."
fc-cache
