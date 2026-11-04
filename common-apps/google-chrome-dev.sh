#!/bin/bash
set -euo pipefail

echoG "========================== Google Chrome =================================="

URL=https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
TMP_DIR=$(mktemp -d)
TMP_FILE="${TMP_DIR}/google-chrome-stable_current_amd64.deb"

echoG "Download..."
wget -O "${TMP_FILE}" "${URL}"
echoG "Install..."
apt install "${TMP_FILE}" -y -qq 2>&1 | tee -a "${LOG_FILE}"
echoG "Cleaning up..."
rm -rf "${TMP_DIR}"


# Create another instance of chrome for development
APP_NAME="Google Chrome Dev"
EXEC_PATH="/usr/bin/google-chrome-stable"
DATA_DIR="${TARGET_HOME}/.config/google-chrome-dev"
CACHE_DIR="${TARGET_HOME}/.cache/google-chrome-dev"
ICON_FILE="google-chrome-dev.png"
ICON_HELPER_FILE="${HELPER_FILES}/$ICON"
StartupWMClass="chrome-dev"
# Define where the .desktop file will be saved
DESKTOP_FILE="${INSTALL_DIR}/applications/google-chrome-dev.desktop"

# Copy icon for dev instance
cp "${ICON_HELPER_FILE}" "${DATA_DIR}"
chown ${TARGET_USER}:${TARGET_USER} "${DATA_DIR}"

# Create desktop icon file with absolute paths
cat <<EOF > "${DESKTOP_FILE}"
[Desktop Entry]
Version=1.0
Type=Application
Name=Google Chrome Dev
GenericName=Google Chrome Dev
Comment=Google Chrome for Development
Exec=${EXEC_PATH} --class=${StartupWMClass} --no-first-run --user-data-dir="${DATA_DIR}" --disk-cache-dir="${CACHE_DIR}" %U
StartupNotify=false
Terminal=false
Icon=${DATA_DIR}/${ICON_FILE}
Categories=Network;WebBrowser;
MimeType=application/pdf;application/rdf+xml;application/rss+xml;application/xhtml+xml;application/xhtml_xml;application/xml;image/gif;image/jpeg;image/png;image/webp;text/html;text/xml;x-scheme-handler/http;x-scheme-handler/https;
Actions=new-window;
StartupWMClass=${StartupWMClass}

[Desktop Action new-window]
Name=New Window
Exec=${EXEC_PATH}
EOF

# Set application permission
chmod +x "${DESKTOP_FILE}"
