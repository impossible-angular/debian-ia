#!/bin/bash
set -euo pipefail

echoG "========================== LTS Node JS =============================="

BASE_URL="https://nodejs.org/dist"
ARCH="linux-x64"
INSTALL_DIR="/usr/local"

echoB "Detecting latest Node.js LTS..."

VERSION=$(curl -fsSL $BASE_URL/index.json | jq -r '[.[] | select(.lts != false)][0].version')
FILE="node-${VERSION}-${ARCH}.tar.xz"
SHAFILE="SHASUMS256.txt"

echoB "Latest LTS: [${VERSION}]"
echoB "Downloading: [${FILE}]"

URL="${BASE_URL}/${VERSION}/${FILE}"
URL_SHA="${BASE_URL}/${VERSION}/${SHAFILE}"
TMP=$(mktemp -d)
NODE_INSTALL_FILE="${TMP}/${FILE}"
NODE_SHA_FILE="${TMP}/${SHAFILE}"

curl -fsSL "${URL}" -o "${NODE_INSTALL_FILE}"
curl -fsSL "${URL_SHA}" -o "${NODE_SHA_FILE}"

echoB "Verifying checksum..."
grep "${NODE_INSTALL_FILE}" ${NODE_SHA_FILE} | sha256sum -c -
echoB "Checksum verified ✔"

echoB "Removing previous Node.js install (if exists)..."
rm -rf \
  "${INSTALL_DIR}/bin/node" \
  "${INSTALL_DIR}/bin/npm" \
  "${INSTALL_DIR}/bin/npx" \
  "${INSTALL_DIR}/include/node" \
  "${INSTALL_DIR}/lib/node_modules" \
  "${INSTALL_DIR}/share/doc/node" \
  "${INSTALL_DIR}/share/systemtap/tapset/node.stp" 2>/dev/null || true

echoB "Extracting..."
tar -xJf "${NODE_INSTALL_FILE}"

echoB "Installing to ${INSTALL_DIR}..."
tar -xJf "${NODE_INSTALL_FILE}" -C ${INSTALL_DIR} --strip-components=1

echoB "Cleaning up..."
rm -rf "${TMP_DIR}"

echoB " node -v: "; node -v;
echoB " npm -v: "; npm -v;
echoG "=========================== Installation complete 🎉 =============================="