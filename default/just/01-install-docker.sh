#!/bin/bash
set -euo pipefail

add_firewall_rules() {
  echo "🧱 Checking firewall status for Docker rules..."
  
  # Check if UFW is installed AND active before proceeding
  if command -v ufw &>/dev/null && sudo ufw status | grep -q "Status: active"; then
    echo "✅ Firewall is active. Applying Docker-specific rules..."
    
    # 1. Install the ufw-docker tool if it's not present
    if ! command -v ufw-docker &>/dev/null; then
      echo -e "⏳ Installing ufw-docker..."
      yay -S --noconfirm ufw-docker
      echo -e "✅ ufw-docker installed"
    fi
    
    # 2. Apply the firewall rules.
    sudo ufw allow in on docker0 to any port 53
    sudo ufw-docker install
    sudo ufw reload
    echo -e "✅ Docker firewall rules applied"
  
  else
    echo "⚠️ UFW is not installed or not active. Skipping Docker firewall rules."
  fi
}

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

    add_firewall_rules

    echo -e "\033c ⚠️ IMPORTANT: Logging out in a moment for group changes to take full effect..."
    sleep 2
    loginctl terminate-user ""
  else
    echo "✅ User '${USER}' is already in the 'docker' group."
  fi
}

install_docker