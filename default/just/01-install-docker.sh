#!/bin/bash
set -euo pipefail

install_docker() {
  echo -e "⏳ Installing Docker packages..."
  yay -S --noconfirm docker docker-compose docker-buildx lazydocker-bin
  echo -e "\033c✅ Docker packages installed"

  if [[ ! -f /etc/docker/daemon.json ]]; then
    # Limit the log size to avoid running out of disk
    sudo mkdir -p /etc/docker
    echo '{"log-driver":"json-file","log-opts":{"max-size":"10m","max-file":"5"}}' | sudo tee /etc/docker/daemon.json >/dev/null
    echo "🔧 Configured Docker daemon with log limits"
  fi

  # Enable the docker service
  # Check the exit code of systemctl
  if ! systemctl is-active --quiet docker.service; then
    echo -e "🔧 Enabling docker service..."
    sudo systemctl enable --now docker.service
    echo -e "✅ Docker service enabled"
  else
    echo -e "✅ Docker service is already enabled"
  fi

  # Prevent Docker from preventing boot for network-online.target
  local DOCKER_SERVICE_D="/etc/systemd/system/docker.service.d"
  if [ ! -d "${DOCKER_SERVICE_D}" ]; then
    sudo mkdir -p "${DOCKER_SERVICE_D}"
  fi

  local NO_BLOCK_BOOT_FILE="${DOCKER_SERVICE_D}/no-block-boot.conf"
  if [ ! -f "${NO_BLOCK_BOOT_FILE}" ]; then
    sudo tee "${NO_BLOCK_BOOT_FILE}" <<'EOF'
[Unit]
DefaultDependencies=no
EOF
  fi

  # Add the current user to the docker group if not already a member
  if ! groups "${USER}" | grep -q '\bdocker\b'; then
    echo "🔧 Adding user '${USER}' to the 'docker' group..."
    sudo usermod -aG docker "${USER}"
    # IMPORTANT: Inform the user they need to re-login
    echo -e "✅ User ${USER} is now part of 'docker' group"
    sleep 2

    echo -e "\033c ⚠️ IMPORTANT: Logging out in a moment for group changes to take full effect..."
    sleep 2
    loginctl terminate-user ""
  else
    echo "✅ User '${USER}' is already in the 'docker' group."
  fi
}

install_docker