#!/bin/bash

echo -e "${GREEN}========================== opera-browser ==============================${NC}"

wget -O opera-browser.deb https://net.geo.opera.com/opera/stable/linux?http_binary=1
apt install ./opera-browser.deb -y 2>&1 | tee -a "$LOG_FILE"
rm opera-browser.deb
