#!/bin/bash

show_menu() {
    clear
    echo "============================================================"
    echo -e "                       ${CYAN}COMMON APPS${NC}"
    echo "============================================================"
    echo "    0) MAIN MENU"
    echo "------------------------------------------------------------"
    echo "    1) All common apps 1x"
    echo "    2) Fonts Jetbrains + terminal"
    echo "    3) File managers"
    echo "    4) Google Chrome with dev profile and icon"
    echo "    5) Tor browser"
    echo "    6) Opera browser"
    echo "------------------------------------------------------------"
    echo "    9) Show Log..."
    echo "------------------------------------------------------------"
}

installed() {
    echo -e "${CYAN}=========================Installation finished==============================${NC}"
    read -p "Press [Enter] to return to the menu..."
}

while true; do
    show_menu
    read -p "Enter choice [0-9]: " choice

    case $choice in
        0) break;;
        1) ./all-tools.sh; installed ;;
        2) ./fonts-jetbrains.sh; installed ;;
        3) ./file-managers.sh; installed ;;
        4) ./google-chrome-dev.sh; installed ;;
        5) ./tor-browser.sh; installed ;;
        6) ./opera-browser.sh; installed ;;
        9) less $LOG_FILE ;;
        *) echo "Invalid option. Press Enter to try again."; read ;;
    esac
done
