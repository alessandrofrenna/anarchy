# Install bluez with utilities (add obex for file sharing)
yay -S --noconfirm --needed bluez bluez-utils bluez-obex bluetui

# Enable bluetooth by default
sudo systemctl enable --now bluetooth.service