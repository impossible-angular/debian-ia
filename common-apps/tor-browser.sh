#!/bin/bash

# 1. Fetch the latest version number from the official JSON API
RELEASE_DATA=$(curl -s https://aus1.torproject.org/torbrowser/update_3/release/downloads.json)

URL_BIN=$(echo ${RELEASE_DATA} | jq -r '.downloads["linux-x86_64"].ALL.binary')
URL_SIG=$(echo ${RELEASE_DATA} | jq -r '.downloads["linux-x86_64"].ALL.sig')
VERSION=$(echo ${RELEASE_DATA} | jq -r '.version')

TMP_DIR=$(mktemp -d)
FILE_BIN="${TMP_DIR}/tor-browser-linux-x86_64-${VERSION}.tar.xz"
FILE_SIG="${TMP_DIR}/tor-browser-linux-x86_64-${VERSION}.tar.xz.asc"

# 2. Download the file
wget -cO "${FILE_BIN}" "${URL_BIN}"
wget -cO "${FILE_SIG}" "${URL_SIG}"

# 3. Verify signature
gpg --list-keys torbrowser@torproject.org > /dev/null 2>&1 || \
gpg --auto-key-locate nodefault,wkd --locate-keys torbrowser@torproject.org
if gpg --verify "${FILE_SIG}" "${FILE_BIN}"; then
   echoB "Signature valid! Proceeding with install..."
else
   echoR "SIGNATURE REJECTED! File may be corrupted or tampered with."
   exit 1
fi

# 4. Install
su - ${TARGET_USER} -c 'tar -xf "$FILE_BIN" -C "$INSTALL_DIR"'
# 5. Register App
cd "${INSTALL_DIR}/tor-browser"
su - ${TARGET_USER} -c "./start-tor-browser.desktop --register-app"

cd -

echoG "Cleaning up..."
rm -rf "${TMP_DIR}"