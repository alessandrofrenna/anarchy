# Exit immediately if a command exits with a non-zero status
set -e

# Give people a chance to retry running the installation
trap 'echo "Anarchy installation failed! You can retry by running: source ~/.local/share/anarchy/install.sh"' ERR

# Check if a path was provided as an argument.
if [ -z "$1" ]; then
  echo "Usage: $0 <installation target, dell|thinkpad>"
  exit 1
fi

# Install everything
for f in ~/.local/share/anarchy/install/*.sh; do
  echo -e "\nRunning installer: $f"
  source "$f"
done

# Install target specific packages
echo -e "\nSelected installation target: $1"
DIRECTORY=~/.local/share/anarchy/install/$1
if [ -d "$DIRECTORY" ]; then
  # If it is a directory, check if it is not empty.
  # The `ls -A` command lists all entries except for '.' and '..'.
  # The `test -n` command checks if the output of `ls -A` is not an empty string.
  if [ -n "$(ls -A "$DIRECTORY")" ]; then
    echo "✅ The path '$DIRECTORY' is a directory and it is not empty. Installing target specific packages"
    for f in ~/.local/share/anarchy/install/$1/*.sh; do
      echo -e "\nRunning installer: $f"
      source "$f"
    done
  else
    echo "🟡 The path '$DIRECTORY' is a directory, but it is empty."
    exit 1
  fi
else
  echo "❌ The path '$DIRECTORY' is not a directory."
  exit 1
fi

# Ensure locate is up to date now that everything has been installed
echo -e "\nUpdating database"
sudo updatedb

# Remove orphaned packages and clean cache
ORPHANCOUNT=$(pacman -Qtdq) | wc -l
if [ $ORPHANCOUNT -gt 0 ]; then
  echo -e "\nRemoving orphan"
  sudo pacman -Rns $(pacman -Qdtq)
else
  echo -e "\nNo orphan package to remove, skipping..."
fi

echo -e "\nCleaning cache"
yes | yay -Scc

sleep 10
echo -e "\nRebooting..."
reboot