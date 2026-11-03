#!/bin/bash

echo -e "${GREEN}========================== youtube-download ==============================${NC}"
YTD_BIN="yt-dlp"
YTD_SH="ytd.sh"

wget -cO "$TARGET_HOME/Music/$YTD_BIN" https://github.com/yt-dlp/yt-dlp/releases/latest/download/yt-dlp
cp "$HELPER_FILES/$YTDSH" "$TARGET_HOME/Music/$YTD_SH"

chown $TARGET_USER:$TARGET_USER "$TARGET_HOME/Music/$YTD_BIN"
chmod +x "$TARGET_HOME/Music/$YTD_BIN"
chown $TARGET_USER:$TARGET_USER "$TARGET_HOME/Music/$YTD_SH"
chmod +x "$TARGET_HOME/Music/$YTD_SH"
