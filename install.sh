# Exit immediately if a command exits with a non-zero status
set -e

# Give people a chance to retry running the installation
trap 'echo "Anarchy installation failed! You can retry by running: source ~/.local/share/anarchy/install.sh"' ERR

for f in ~/.local/share/anarchy/install/utils/*.sh; do
  source "$f"
done

# Install everything
for f in ~/.local/share/anarchy/install/*.sh; do
  echo -e "\nRunning installer: $f"
  source "$f"
done

# Ensure locate is up to date now that everything has been installed
echo -e "\nUpdating database"
sudo updatedb

# Remove orphaned packages and clean cache
ORPHANCOUNT=$(pacman -Qtdq | wc -l)
if [ $ORPHANCOUNT -gt 0 ]; then
  echo -e "\nRemoving orphans..."
  sudo pacman -Rns $(pacman -Qdtq) --noconfirm
else
  echo -e "\nNo orphan package to remove, skipping..."
fi

echo -e "\nCleaning cache"
yes | yay -Scc

echo -e "\nSetup completed, rebooting soon..."s
sleep 5
echo -e "\nRebooting..."
sudo systemctl reboot