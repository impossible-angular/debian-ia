#!/bin/bash

set -euo pipefail

echoG "====================================== DBeaver ===================================="

BASE_URL="https://dbeaver.io/files"
ARCH="amd64"
TMP=$(mktemp -d)

echoG "Fetching latest DBeaver CE version..."

LATEST_DEB=$(curl -fsSL "${BASE_URL}/" | grep -oP "dbeaver-ce-[0-9.]+_amd64.deb" | sort -V | tail -n1)

if [ -z "${LATEST_DEB}" ]; then
  echoR "Could not determine latest DBeaver CE package"
  exit 1
fi
echoB "Latest DBeaver CE package identified: ${LATEST_DEB}"

DEB_URL="${BASE_URL}/${LATEST_DEB}"
CHECKSUM_URL="${BASE_URL}/checksum/${LATEST_DEB}.sha256"
DBEAVER_INSTALL_FILE="${TMP}/${LATEST_DEB}"
DBEAVER_CHECKSUM_FILE="${TMP}/${LATEST_DEB}.sha256"

echoG "Downloading .deb and SHA256 checksum..."
curl -fsSL "${DEB_URL}" -o "${DBEAVER_INSTALL_FILE}"
curl -fsSL "${CHECKSUM_URL}" -o "${DBEAVER_CHECKSUM_FILE}"

# 4) Verify checksum
EXPECTED_HASH=$(cut -d' ' -f1 < "${DBEAVER_CHECKSUM_FILE}")
ACTUAL_HASH=$(sha256sum "${DBEAVER_INSTALL_FILE}" | cut -d' ' -f1)

if [ "${EXPECTED_HASH}" != "${ACTUAL_HASH}" ]; then
  echoR "Checksum mismatch! Aborting installation."
  exit 1
fi
echoB "Checksum OK ✔"

# 5) Install
echoG "Installing DBeaver CE..."
dpkg -i "${DBEAVER_INSTALL_FILE}"

# fix missing dependencies if any
apt-get install -f -y

echoG "Cleaning up..."
rm -rf "${TMP_DIR}"
