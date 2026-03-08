#!/bin/bash

wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
apt install ./google-chrome-stable_current_amd64.deb -y -qq 2>&1 | tee -a "$LOG_FILE"
rm google-chrome-stable_current_amd64.deb


# 1. Define your absolute paths using $HOME
# This ensures the .desktop file gets /home/username/... instead of ~/
APP_NAME="Google Chrome Dev"
EXEC_PATH="/usr/bin/google-chrome-stable"
DATA_DIR="$TARGET_HOME/.config/google-chrome-dev"
CACHE_DIR="$TARGET_HOME/.cache/google-chrome-dev"
ICON="google-chrome-dev.png"
StartupWMClass="chrome-dev"

# 2. Define where the .desktop file will be saved
DESKTOP_FILE="$INSTALL_DIR/applications/google-chrome-dev.desktop"
cp "$ICON" "$DATA_DIR"
chown $TARGET_USER:$TARGET_USER $DATA_DIR

# 3. Create the file with absolute paths
cat <<EOF > "$DESKTOP_FILE"
[Desktop Entry]
Version=1.0
Type=Application
Name=Google Chrome Dev
GenericName=Google Chrome Dev
Comment=Google Chrome for Development
Exec=$EXEC_PATH --class=$StartupWMClass --no-first-run --user-data-dir="$DATA_DIR" --disk-cache-dir="$CACHE_DIR" %U
StartupNotify=false
Terminal=false
Icon=$DATA_DIR/$ICON
Categories=Network;WebBrowser;
MimeType=application/pdf;application/rdf+xml;application/rss+xml;application/xhtml+xml;application/xhtml_xml;application/xml;image/gif;image/jpeg;image/png;image/webp;text/html;text/xml;x-scheme-handler/http;x-scheme-handler/https;
Actions=new-window;
StartupWMClass=$StartupWMClass

[Desktop Action new-window]
Name=New Window
Exec=$EXEC_PATH
EOF

# 4. Set application permition
#chmod 644 "$DESKTOP_FILE"
chmod +x "$DESKTOP_FILE"
