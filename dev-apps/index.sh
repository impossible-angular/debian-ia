#!/bin/bash

show_menu() {
    clear
    echo "============================================================"
    echo -e "                       ${CYAN}DEV APPS${NC}"
    echo "============================================================"
    echo "    0) MAIN MENU"
    echo "------------------------------------------------------------"
    echo "    1) All dev apps 1x"
    echo "    2) WebStorm"
    echo "    3) DBeaver"
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
        2) ./webstorm.sh; installed ;;
        3) ./dbeaver-ce.sh; installed ;;
        9) less $LOG_FILE ;;
        *) echo "Invalid option. Press Enter to try again."; read ;;
    esac
done
