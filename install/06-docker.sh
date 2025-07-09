# Install docker, docker-compose and lazydocker
yay -S --noconfirm --needed docker docker-compose lazydocker-bin

echo "Ensure Docker config is set"
if [[ ! -f /etc/docker/daemon.json ]]; then
  # Limit the log size to avoid running out of disk
  sudo mkdir -p /etc/docker
  echo '{"log-driver":"json-file","log-opts":{"max-size":"10m","max-file":"5"}}' | sudo tee /etc/docker/daemon.json
fi

# Enable the docker service
docker_status="$(systemctl is-active docker.service)"
if [ "${docker_status}" = "inactive" ]; then
  echo -e "\nEnabling docker service..."
  sudo systemctl enable --now docker.service
else
  echo -e "\nDocker already enabled"
fi


# Add the current user to the docker group
sudo usermod -aG docker ${USER}
