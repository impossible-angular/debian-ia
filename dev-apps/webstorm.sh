#!/bin/bash

# 1. Download the latest WebStorm tarball
wget -cO webstorm.tar.gz "https://data.services.jetbrains.com/products/download?platform=linux&code=WS"

# 2. Create the target directory (if it doesn't exist)
mkdir -p /opt/webstorm

# 3. Extract the contents into /opt/webstorm
# --strip-components=1 ensures the files go directly into the folder
tar -xzf webstorm.tar.gz -C /opt/webstorm --strip-components=1
rm webstorm.tar.gz

# 4. Create a Symlink (For Terminal Access)
ln -s /opt/webstorm/bin/webstorm.sh /usr/local/bin/webstorm

DESKTOP_FILE="$INSTALL_DIR/applications/webstorm.desktop"
# 5. Create the Dash Icon
cat <<EOF > "$DESKTOP_FILE"
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

# 4. Final Permission Check
chmod +x /opt/webstorm/bin/webstorm.sh
