# Install docker, docker-compose and lazydocker
yay -S --noconfirm --needed docker docker-compose lazydocker-bin

# Limit the log size to avoid running out of disk
sudo mkdir -p /etc/docker
echo '{"log-driver":"json-file","log-opts":{"max-size":"10m","max-file":"5"}}' | sudo tee /etc/docker/daemon.json

# Enable the docker service
sudo systemctl enable --now docker.service

# Add the current user to the docker group
sudo usermod -aG docker ${USER}
