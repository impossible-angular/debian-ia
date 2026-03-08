#!/bin/bash

# Fonts
echo -e "${GREEN}==========================Fonts from JetBrains==============================${NC}"

sudo apt-get install -y -qq keepassxc 2>&1 | tee -a "$LOG_FILE"

sudo apt-get install -y -qq rclone 2>&1 | tee -a "$LOG_FILE"

# Define where the .desktop file will be saved
KEEPASSXC_DIR="$INSTALL_DIR/keepassxc"
mkdir $KEEPASSXC_DIR
chown $TARGET_USER:$TARGET_USER $KEEPASSXC_DIR
DESKTOP_FILE="$INSTALL_DIR/applications/keepassxc-sync.desktop"

# Create the file with absolute paths
cat <<EOF > "$DESKTOP_FILE"
[Desktop Entry]
Version=1.0
Type=Application
Name=KeePass Dropbox Sync
Comment=Sync and Open KeePass Database
# Update the path below to your actual script location
Exec=$KEEPASSXC_DIR/keepassxc-sync.sh
Icon=keepassxc
Terminal=true
Categories=Utility;Security;
EOF

# Set application permition
chown $TARGET_USER:$TARGET_USER $DESKTOP_FILE
chmod +x "$DESKTOP_FILE"

cp ./keepassxc-sync.sh $KEEPASSXC_DIR
chmod +x $KEEPASSXC_DIR/keepassxc-sync.sh

echo -e "${GREEN} === setup rclone for drop box === ${NC}"
rclone config create dropbox dropbox
