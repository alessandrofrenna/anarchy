pacman -Q git &>/dev/null || sudo pacman -Sy --noconfirm --needed git

echo -e "\nCloning Anarchy..."
rm -rf ~/.local/share/anarchy/
git clone https://github.com/alessandrofrenna/anarchy.git ~/.local/share/anarchy >/dev/null

pacman -Q wget &>/dev/null || sudo pacman -Sy --noconfirm --needed wget

echo -e "\nInstallation starting..."
source ~/.local/share/anarchy/install.sh $1