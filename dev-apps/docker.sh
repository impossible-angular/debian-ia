#!/bin/bash

#set -euo pipefail

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

if [ "${choice^^}" = 'Y' ]; then
  systemctl start docker
fi

echoB "Testing docker under ROOT"

docker run hello-world


echoG "====================================== Add user to docker group and test docker under this user =============="

usermod -aG docker ${TARGET_USER}
su - ${TARGET_USER} -c "docker run hello-world"

echoG "====================================== Install Docker Desktop  ===================================="

read -p " Install? - [y/n]" choice
if [ "${choice^^}" != 'Y' ]; then
  exit 1
fi

URL_DOCKER_DESKTOP=https://desktop.docker.com/linux/main/amd64/docker-desktop-amd64.deb
TMP_DIR=$(mktemp -d)
DOCKER_DESKTOP_INSTALL_FILE="${TMP_DIR}/docker-desktop-amd64.deb"

wget -cO "${DOCKER_DESKTOP_INSTALL_FILE}" "${URL_DOCKER_DESKTOP}"

apt-get install "${DOCKER_DESKTOP_INSTALL_FILE}"

echoR "Ignore this message."
echoG "couldn't be accessed by user '_apt'. - pkgAcquire::Run (13: Permission denied)"

echoG "Cleaning up..."
rm -rf "${TMP_DIR}"

echoR "Generate gpg key"
echoB "gpg --generate-key"
echoR "Pass it"
echoB "pass init example-3ABCD1234EF56G78-example"