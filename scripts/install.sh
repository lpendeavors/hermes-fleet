#!/usr/bin/env bash
set -e

echo "=== Band Director VPS Bootstrap ==="

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
chown -R $SUDO_USER:$SUDO_USER /opt/hermes-fleet

# Setup firewall
ufw default deny incoming
ufw default allow outgoing
ufw allow ssh
ufw --force enable

echo "=== Bootstrap complete ==="
echo "Next steps:"
echo "1. Clone your repo: cd /opt/hermes-fleet && git clone <your-repo> ."
echo "2. Create .env file with your secrets"
echo "3. Run: docker compose up -d"
