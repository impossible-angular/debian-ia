#!/bin/bash

# Gimp
echo -e "${GREEN}=========================== gimp =================================${NC}"

apt-get update
apt-get install -y -qq gimp 2>&1 | tee -a "$LOG_FILE"
