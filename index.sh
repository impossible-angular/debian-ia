#!/bin/bash

# Define Colors
export RED='\033[1;31m'
export GREEN='\033[1;32m'
export CYAN='\033[1;36m'
export NC='\033[0m' # No Color (Reset)
export LOG_FILE="$(pwd)/install_log.txt"

# Ask for the target user (the person who will use all apps)
export TARGET_USER=$1
if [ -z "$TARGET_USER" ]; then
  echo "============================================================"
  read -p "  Enter the username for the installation target: " TARGET_USER
fi
export TARGET_HOME=$(getent passwd $TARGET_USER | cut -d: -f6)
export INSTALL_DIR="$TARGET_HOME/.local/share"

# Check if the script is actually running as root
if [ "$EUID" -ne 0 ]; then
  echo -e "${RED}Error: Please run this script with 'su -' or 'sudo'.${NC}"
  exit 1
fi

chmod -R 744 $(pwd)

# Verify if user exists and has a home directory
if ! id "$TARGET_USER" &>/dev/null || [ ! -d "/home/$TARGET_USER" ]; then
    echo -e "${RED}Error: User ${CYAN}${TARGET_USER}${RED} does not exist or has no home directory.${NC}"
    exit 1
fi

# Main menu
show_menu() {
    clear
    echo "============================================================"
    echo "                 MY DEBIAN SETUP SCRIPTS"
    echo -e "           ${GREEN}Verified: User ${RED}${TARGET_USER}${GREEN} found at ${RED}$TARGET_HOME${NC}"
    echo "============================================================"
    echo "  1) Common Apps"
    echo "  2) Dev Apps"
    echo "  3) Media Apps"
    echo "  0) or Ctrl+C Exit"
    echo "------------------------------------------------------------"
}

finish() {
  echo
  echo "------------------------------------------------"
  echo "  Script execution finished. Goodbye, $TARGET_USER!"
  echo "------------------------------------------------"
}

while true; do
    show_menu
    read -p "  Enter choice [1-4]: " choice

    case $choice in
        1)
            cd common-apps && ./index.sh
            cd ..
            ;;
        2)
            cd dev-apps && ./index.sh
            cd ..
            ;;
        3)
            cd media-apps && ./index.sh
            cd ..
            ;;
        0)
           finish
           break
           ;;
        *) echo "  Invalid option. Press Enter to try again."; read ;;
    esac
done
