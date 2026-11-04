#!/bin/bash
set -euo pipefail

echoG "========================== JetBrainsMono fonts =================================="

URL="https://download.jetbrains.com/fonts/JetBrainsMono-latest.zip"
TMP_DIR=$(mktemp -d)
FONT_ZIP="${TMP_DIR}/JetBrainsMono.zip"

echoG "Downloading JetBrains Mono..."
curl -fsSL "${URL}" -o "${FONT_ZIP}"

echoG "Extracting fonts..."
unzip -q "${FONT_ZIP}" -d "${TMP_DIR}"

echoG "Installing fonts system-wide..."
mkdir -p /usr/local/share/fonts/jetbrains-mono
cp "${TMP_DIR}/fonts/ttf/*.ttf" /usr/local/share/fonts/jetbrains-mono/

echoG "Updating font cache..."
fc-cache -f -v

echoG "Cleaning up..."
rm -rf "${TMP_DIR}"

echoG "==================== JetBrains Mono installed successfully ✔ ===================="

echoG "==================== Apply JetBrains Mono 14 font to terminal ==================="

# get terminal profile id for $TARGET_USER
PROFILE_ID=$(su - "${TARGET_USER}" -c "dbus-run-session gsettings get org.gnome.Terminal.ProfilesList default" | tr -d "'")
FONT_NAME='JetBrains Mono 14'

# set font for $TARGET_USER
su - "${TARGET_USER}" <<EOF
dbus-run-session gsettings set org.gnome.Terminal.Legacy.Profile:/org/gnome/terminal/legacy/profiles:/:${PROFILE_ID}/ use-system-font false;
dbus-run-session gsettings set org.gnome.Terminal.Legacy.Profile:/org/gnome/terminal/legacy/profiles:/:${PROFILE_ID}/ font '${FONT_NAME}';
EOF
# show setting
echoG "${TARGET_USER} PROFILE_ID: ${PROFILE_ID}"
su - ${TARGET_USER} -c "dbus-run-session gsettings get org.gnome.Terminal.Legacy.Profile:/org/gnome/terminal/legacy/profiles:/:${PROFILE_ID}/ use-system-font"
su - ${TARGET_USER} -c "dbus-run-session gsettings get org.gnome.Terminal.Legacy.Profile:/org/gnome/terminal/legacy/profiles:/:${PROFILE_ID}/ font"

# set font for root
PROFILE_ID=$(gsettings get org.gnome.Terminal.ProfilesList default | tr -d "'")
gsettings set org.gnome.Terminal.Legacy.Profile:/org/gnome/terminal/legacy/profiles:/:${PROFILE_ID}/ use-system-font false
gsettings set org.gnome.Terminal.Legacy.Profile:/org/gnome/terminal/legacy/profiles:/:${PROFILE_ID}/ font '$FONT_NAME'

echoG "root PROFILE_ID: ${PROFILE_ID}"
echoG "==================== Restarting terminal to apply font... ======================="
