yay -S --noconfirm powertop power-profiles-daemon

sudo systemctl enable --now power-profiles-daemon.service

if ls /sys/class/power_supply/BAT* &>/dev/null; then
  # This computer runs on a battery
  powerprofilesctl set power-saver || true
else
  # This computer runs on power outlet
  powerprofilesctl set balanced || true
fi