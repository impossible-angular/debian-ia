#!/bin/bash

# Configuration
REMOTE_PATH="dropbox:keepass/sv.kdbx"
LOCAL_TMP="/tmp/sv.kdbx"
BACKUP_DIR="$HOME/Documents/KeePass_Backups"
HASH_FILE="/tmp/db_hash.txt"

# Add this near the top of the script to keep only the last 5 days of backups
find "$BACKUP_DIR" -name "*.kdbx" -type f -mtime +5 -delete

# Create backup directory if it doesn't exist
mkdir -p "$BACKUP_DIR"

# 1. Download from Dropbox
echo -e "\033[1;36mPulling latest database from Dropbox...\033[0m"
rclone copy "$REMOTE_PATH" /tmp/

if [ ! -f "$LOCAL_TMP" ]; then
    echo -e "\033[1;31mError: Could not download database from Dropbox.\033[0m"
    exit 1
fi

# 2. Create local backup before opening
# Filename format: database_2026-03-01_23-15.kdbx
cp "$LOCAL_TMP" "$BACKUP_DIR/database_$(date +%F_%H-%M).kdbx"
echo "Local backup created in $BACKUP_DIR"

# 3. Take a snapshot to track changes
sha256sum "$LOCAL_TMP" > "$HASH_FILE"

# 4. Open with KeePassXC
echo -e "\033[1;33mOpening KeePassXC. Close the app to trigger sync...\033[0m"
keepassxc "$LOCAL_TMP" 2>/dev/null

# 5. Check if the file changed and upload
if ! sha256sum -c "$HASH_FILE" --status; then
    echo -e "\033[1;32mChanges detected! Syncing back to Dropbox...\033[0m"
    # Note: We use 'copyto' to ensure the filename stays exactly as intended
    rclone copyto "$LOCAL_TMP" "$REMOTE_PATH"
    echo "✅ Sync Complete."
else
    echo "No changes made. Dropbox remains untouched."
fi

# 6. Clean up the sensitive temp file
rm "$LOCAL_TMP" "$HASH_FILE"
echo "Session cleaned up."