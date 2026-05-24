#!/usr/bin/env bash
set -euo pipefail

# Root check
if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root or with sudo" 
   exit 1
fi

echo "=== Band Director VPS Bootstrap ==="

# Detect OS
if ! command -v lsb_release &> /dev/null; then
    apt-get update && apt-get install -y lsb-release
fi

DISTRO=$(lsb_release -is | tr '[:upper:]' '[:lower:]')
CODENAME=$(lsb_release -cs)

if [[ "$DISTRO" != "ubuntu" && "$DISTRO" != "debian" ]]; then
    echo "Unsupported distro: $DISTRO. Only Ubuntu/Debian supported."
    exit 1
fi

# Update system
apt-get update
apt-get install -y \
    apt-transport-https \
    ca-certificates \
    curl \
    gnupg \
    lsb-release \
    git \
    ufw

# Install Docker
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg

echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null

apt-get update
apt-get install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin

# Enable Docker
systemctl enable docker
systemctl start docker

# Create app directory
mkdir -p /opt/hermes-fleet

# Set ownership (handle both sudo and root cases)
TARGET_USER="${SUDO_USER:-${USER:-root}}"
chown -R "$TARGET_USER:$TARGET_USER" /opt/hermes-fleet

# Add user to docker group if not root
if [[ "$TARGET_USER" != "root" ]]; then
    usermod -aG docker "$TARGET_USER"
    echo "Added $TARGET_USER to docker group (logout/login required)"
fi

# Setup firewall safely
DEFAULT_SSH_PORT=$(grep -oP '^Port\s+\K[0-9]+' /etc/ssh/sshd_config 2>/dev/null || echo "22")
ufw default deny incoming
ufw default allow outgoing
ufw allow "$DEFAULT_SSH_PORT/tcp"

# Enable firewall
ufw --force enable

echo "=== Bootstrap complete ==="
echo "Firewall configured to allow SSH on port $DEFAULT_SSH_PORT"
echo "Next steps:"
echo "1. Clone your repo: cd /opt/hermes-fleet && git clone <your-repo> ."
echo "2. Create .env file with your secrets"
echo "3. Run: docker compose up -d"
