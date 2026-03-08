#!/bin/bash

# File managers: Double Commander, Midnight Commander
echo -e "${GREEN}===========================Double Commander=================================${NC}"

apt-get install -y -qq doublecmd-qt 2>&1 | tee -a "$LOG_FILE"



echo -e "${GREEN}==========================Midnight Commander================================${NC}"

apt-get install -y -qq mc 2>&1 | tee -a "$LOG_FILE"
