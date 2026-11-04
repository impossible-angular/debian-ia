#!/bin/bash

set -euo pipefail

URL="https://data.services.jetbrains.com/products/download?platform=linux&code=WS"
TMP=$(mktemp -d)
WEBSTORM_INSTALL_FILE="${TMP}/webstorm.tar.gz"
INSTALL_DIR="/opt/webstorm"

# Download the latest WebStorm tarball
wget -cO "${WEBSTORM_INSTALL_FILE}" "${URL}"

# Create the target directory (if it doesn't exist)
mkdir -p "${INSTALL_DIR}"

# Extract the contents into /opt/webstorm
# --strip-components=1 ensures the files go directly into the folder
tar -xzf "${WEBSTORM_INSTALL_FILE}" -C "${INSTALL_DIR}" --strip-components=1

echoB "Cleaning up..."
rm -rf "${TMP_DIR}"

# Create a Symlink (For Terminal Access)
ln -s /opt/webstorm/bin/webstorm.sh /usr/local/bin/webstorm

DESKTOP_FILE="${INSTALL_DIR}/applications/webstorm.desktop"
# 5. Create the Dash Icon
cat <<EOF > "${DESKTOP_FILE}"
[Desktop Entry]
Version=1.0
Type=Application
Name=WebStorm
Icon=/opt/webstorm/bin/webstorm.svg
Exec="/opt/webstorm/bin/webstorm.sh" %f
Comment=The smartest JavaScript IDE
Categories=Development;IDE;
Terminal=false
StartupWMClass=jetbrains-webstorm
EOF

# Final Permission Check
chmod +x /opt/webstorm/bin/webstorm.sh
