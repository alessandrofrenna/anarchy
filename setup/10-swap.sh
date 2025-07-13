make_swap_file() {
  local swap_size=$(free | awk '/Mem/ {x=$2/1024/1024; printf "%.0fG", (x<2 ? 2*x : x<8 ? 1.5*x : x) }')
  
  echo "System RAM detected. Creating a ${swap_size} swap file..."
  sudo fallocate -l "${swap_size}" /swapfile
  sudo chmod 600 /swapfile
  sudo mkswap /swapfile
  
  # Make the swap permanent after reboot ---
  echo "Adding swap file to /etc/fstab for persistence..."
  echo '/swapfile none swap sw 0 0' | sudo tee -a /etc/fstab >/dev/null
}

start_swap() {
  echo "Activating swap file..."
  sudo swapon /swapfile
}

if [ ! -f "/swapfile" ]; then
  echo "No /swapfile found. Starting creation process..."
  make_swap_file
  start_swap
  echo "Swap file created and activated successfully."
else
  echo "/swapfile already exists. Ensuring it is active..."
  # If the file exists but swap isn't on, turn it on.
  if ! swapon --show | grep -q '/swapfile'; then
    start_swap
    echo "Swap file activated."
  else
    echo "Swap is already active."
  fi
fi