#!/bin/bash

# Fonts
echo -e "${GREEN}==========================Fonts from JetBrains==============================${NC}"

apt-get install -y -qq fonts-jetbrains-mono 2>&1 | tee -a "$LOG_FILE"

# Apply this font to all installed applications.
echo Apply this font to terminal
