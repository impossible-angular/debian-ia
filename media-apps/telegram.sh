#!/bin/bash

echo -e "${GREEN}========================== telegram-desktop ==============================${NC}"

apt-get install -y -qq telegram-desktop 2>&1 | tee -a "$LOG_FILE"
