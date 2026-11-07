#!/bin/bash

set -euo pipefail

echoG "====================================== Docker ===================================="

# Add Docker's official GPG key:
apt update
apt install ca-certificates curl
install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/debian/gpg -o /etc/apt/keyrings/docker.asc
chmod a+r /etc/apt/keyrings/docker.asc

# Add the repository to Apt sources:
tee /etc/apt/sources.list.d/docker.sources <<EOF
Types: deb
URIs: https://download.docker.com/linux/debian
Suites: $(. /etc/os-release && echo "$VERSION_CODENAME")
Components: stable
Architectures: $(dpkg --print-architecture)
Signed-By: /etc/apt/keyrings/docker.asc
EOF

apt update

# Install Docker core and cli
apt install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

systemctl status docker --no-pager

echoB "If Docker is not running, start it manually."
read -p " Run [systemctl status docker] - [y/n]" choice

if [[ "$choice" = 'y' || "$choice" = 'Y' ]]; then
  systemctl start docker
fi

echoB "Testing docker..."

docker run hello-world
