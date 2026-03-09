#!/bin/bash

# Fonts
echo -e "${GREEN}========================== Fonts from JetBrains ==============================${NC}"

apt-get install -y -qq fonts-jetbrains-mono 2>&1 | tee -a "$LOG_FILE"


echo -e "${GREEN}=================== Apply JetBrains Mono 14 font to terminal ========================${NC}"

PROFILE_ID=$(su - "$TARGET_USER" -c "dbus-run-session gsettings get org.gnome.Terminal.ProfilesList default" | tr -d "'")
FONT_NAME='JetBrains Mono 14'

# set font for $TARGET_USER
su - "$TARGET_USER" <<EOF
dbus-run-session gsettings set org.gnome.Terminal.Legacy.Profile:/org/gnome/terminal/legacy/profiles:/:$PROFILE_ID/ use-system-font false;
dbus-run-session gsettings set org.gnome.Terminal.Legacy.Profile:/org/gnome/terminal/legacy/profiles:/:$PROFILE_ID/ font '$FONT_NAME';
EOF

echo "$TARGET_USER PROFILE_ID: $PROFILE_ID"
su - $TARGET_USER -c "dbus-run-session gsettings get org.gnome.Terminal.Legacy.Profile:/org/gnome/terminal/legacy/profiles:/:$PROFILE_ID/ use-system-font"
su - $TARGET_USER -c "dbus-run-session gsettings get org.gnome.Terminal.Legacy.Profile:/org/gnome/terminal/legacy/profiles:/:$PROFILE_ID/ font"

# set font for root
PROFILE_ID=$(gsettings get org.gnome.Terminal.ProfilesList default | tr -d "'")
gsettings set org.gnome.Terminal.Legacy.Profile:/org/gnome/terminal/legacy/profiles:/:$PROFILE_ID/ use-system-font false
gsettings set org.gnome.Terminal.Legacy.Profile:/org/gnome/terminal/legacy/profiles:/:$PROFILE_ID/ font '$FONT_NAME'

echo "root PROFILE_ID: $PROFILE_ID"
echo "Restarting terminal to apply font..."
