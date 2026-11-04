#!/bin/bash
set -euo pipefail

echoG "========================== Keepass =================================="

apt-get install -y -qq keepassxc 2>&1 | tee -a "${LOG_FILE}"
apt-get install -y -qq rclone 2>&1 | tee -a "${LOG_FILE}"

# Define where the .desktop file will be saved
KEEPASSXC_DIR="${INSTALL_DIR}/keepassxc"
DESKTOP_FILE="${INSTALL_DIR}/applications/keepassxc-sync.desktop"
KEEPASSXC_EXEC_SCRIPT="${KEEPASSXC_DIR}/keepassxc-sync.sh"
KEEPASSXC_HELPER_SCRIPT="${HELPER_FILES}/keepassxc-sync.sh"

mkdir "${KEEPASSXC_DIR}"
chown ${TARGET_USER}:${TARGET_USER} "${KEEPASSXC_DIR}"

# Create the file with absolute paths
cat <<EOF > "${DESKTOP_FILE}"
[Desktop Entry]
Version=1.0
Type=Application
Name=KeePass Dropbox Sync
Comment=Sync and Open KeePass Database
# Update the path below to your actual script location
Exec=${KEEPASSXC_EXEC_SCRIPT}
Icon=keepassxc
Terminal=true
Categories=Utility;Security;
EOF

# Set application permition
chown ${TARGET_USER}:${TARGET_USER} ${DESKTOP_FILE}
chmod +x "${DESKTOP_FILE}"

cp "${KEEPASSXC_HELPER_SCRIPT}" ${KEEPASSXC_DIR}
chmod +x "${KEEPASSXC_HELPER_SCRIPT}"

echoG "==================== setup rclone for drop box ======================="

rclone config create dropbox dropbox
