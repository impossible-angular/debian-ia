#!/bin/bash

echo -e "${GREEN}========================== tools ==============================${NC}"
echo -e "${GREEN} btop ${NC}"

apt-get install -y -qq btop 2>&1 | tee -a "$LOG_FILE"
