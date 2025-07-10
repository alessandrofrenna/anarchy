source "$HOME/.local/share/anarchy/setup/utils/is_installed.sh"

required_packages=(
  "noto-fonts" "noto-fonts-emoji" "noto-fonts-cjk" "noto-fonts-extra"
  "ttf-nerd-fonts-symbols" "ttf-nerd-fonts-symbols-mono" "ttf-terminus-nerd"
  "ttf-jetbrains-mono-nerd" "ttf-firacode-nerd" "ttf-dejavu-nerd" "ttf-roboto-mono-nerd"
  "ttf-noto-nerd" "nerd-fonts-inter"
)

to_install=()
for i in "${!required_packages[@]}"; do
  pkg_name="${packages_to_install[$i]}"
  check=$(is_installed ${pkg_name})
  if [ $check -eq 1 ]; then
    to_install+=(${pkg_name})
  fi
done

echo -e "\nInstalling fonts..."
[[ -z $to_install ]] && yay -S --noconfirm --needed ${to_install}

echo -e "\nReloading font cache..."
fc-cache
