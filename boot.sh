pacman -Q git &>/dev/null || sudo pacman -Sy --noconfirm --needed git
clear

echo -e "⏳ Cloning Anarchy..."
rm -rf ~/.local/share/anarchy/
git clone https://github.com/alessandrofrenna/anarchy.git ~/.local/share/anarchy >/dev/null
clear

echo -e "⏳ Installation starting..."
sleep 3
clear
source ~/.local/share/anarchy/install.sh