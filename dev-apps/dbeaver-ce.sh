#!/bin/bash

set -euo pipefail

echo -e "${GREEN}========================== DBeaver ==============================${NC}"

BASE_URL="https://dbeaver.io/files"
ARCH="amd64"
TMP=$(mktemp -d)
cd "$TMP"


echo -e "${GREEN} Fetching latest DBeaver CE version...${NC}"

LATEST_DEB=$(curl -fsSL "${BASE_URL}/" | grep -oP "dbeaver-ce-[0-9.]+_amd64.deb" | sort -V | tail -n1)

if [ -z "$LATEST_DEB" ]; then
  echo -e "${RED} Could not determine latest DBeaver CE package${NC}"
  exit 1
fi
echo -e "${GREEN} Latest DBeaver CE package identified: $LATEST_DEB ${NC}"

DEB_URL="${BASE_URL}/${LATEST_DEB}"
CHECKSUM_URL="${BASE_URL}/checksum/${LATEST_DEB}.sha256"

echo -e "${GREEN} Downloading .deb and SHA256 checksum... ${NC}"
curl -fsSLO "$DEB_URL"
curl -fsSLO "$CHECKSUM_URL"

# 4) Verify checksum
EXPECTED_HASH=$(cut -d' ' -f1 < "${LATEST_DEB}.sha256")
ACTUAL_HASH=$(sha256sum "${LATEST_DEB}" | cut -d' ' -f1)

if [ "$EXPECTED_HASH" != "$ACTUAL_HASH" ]; then
  echo -e "${RED} Checksum mismatch! Aborting installation. ${NC}"
  exit 1
fi


echo -e "${GREEN} Checksum OK ✔ ${NC}"

# 5) Install
echo "Installing DBeaver CE..."
sudo dpkg -i "$LATEST_DEB"

# fix missing dependencies if any
apt-get install -f -y

echo "Installation completed successfully!"


#wget -q -O - https://dbeaver.io/debs/dbeaver.gpg.key | gpg --dearmor -o /usr/share/keyrings/dbeaver.gpg.key
#echo "deb [signed-by=/usr/share/keyrings/dbeaver.gpg.key] https://dbeaver.io/debs/dbeaver-ce /" | tee /etc/apt/sources.list.d/dbeaver.list
#apt-get update
#apt-get install -y -qq dbeaver-ce  2>&1 | tee -a "$LOG_FILE"
