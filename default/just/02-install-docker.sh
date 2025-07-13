source "$HOME/.local/share/anarchy/setup/utils/is_installed.sh"

install_docker() {
  echo "Checking for required Docker packages..."

  required_packages=("docker" "docker-compose" "lazydocker-bin")
  to_install=()
  for pkg_name in "${required_packages[@]}"; do
    if ! is_installed "${pkg_name}"; then
      to_install+=("${pkg_name}")
    fi
  done

  if [[ ${#to_install[@]} -gt 0 ]]; then
    echo "Installing missing packages: ${to_install[*]}"
    yay -S --noconfirm "${to_install[@]}"
  else
    echo "All Docker packages are already installed"
  fi

  if [[ ! -f /etc/docker/daemon.json ]]; then
    echo "Configuring Docker daemon with log limits..."
    # Limit the log size to avoid running out of disk
    sudo mkdir -p /etc/docker
    echo '{"log-driver":"json-file","log-opts":{"max-size":"10m","max-file":"5"}}' | sudo tee /etc/docker/daemon.json >/dev/null
  fi

  # Enable the docker service
  # Check the exit code of systemctl
  if ! systemctl is-active --quiet docker.service; then
    echo -e "Enabling docker service..."
    sudo systemctl enable --now docker.service
  else
    echo -e "Docker service is already active."
  fi

  # Add the current user to the docker group if not already a member
  if ! groups "${USER}" | grep -q '\bdocker\b'; then
    echo "Adding user '${USER}' to the 'docker' group..."
    sudo usermod -aG docker "${USER}"
    # IMPORTANT: Inform the user they need to re-login
    echo -e "IMPORTANT: Log out and log back in for group changes to take full effect."
  else
    echo "User '${USER}' is already in the 'docker' group."
  fi
}

set -e
install_docker