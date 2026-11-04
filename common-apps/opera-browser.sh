#!/bin/bash
set -euo pipefail

echoG "========================== Opera browser =================================="

TMP_DIR=$(mktemp -d)
TMP_FILE="${TMP_DIR}/opera-browser.deb"

LATEST_VERSION=$(wget -qO- https://ftp.opera.com/pub/opera/desktop/ | grep -Po 'href="\K.*?(?=/")' | sort -V | tail -n1)
URL="https://ftp.opera.com/pub/opera/desktop/${LATEST_VERSION}/linux/opera-stable_${LATEST_VERSION}_amd64.deb"

wget -O "${TMP_FILE}" "${URL}"

apt install "${TMP_FILE}" -y 2>&1 | tee -a "${LOG_FILE}"

echoG "Cleaning up..."
rm -rf "${TMP_DIR}"
