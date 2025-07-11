# GNOME keyring configuration
sudo bash -c 'cat >> /etc/pam.d/passwd << 'EOF'
password        optional        pam_gnome_keyring.so
EOF'

sudo bash -c 'cat >> /etc/pam.d/login << 'EOF'
auth       optional     pam_gnome_keyring.so
EOF'