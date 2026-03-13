#!/bin/bash

echo -e "${GREEN}========================== opera-browser ==============================${NC}"

LATEST_VERSION=$(wget -qO- https://ftp.opera.com/pub/opera/desktop/ | grep -Po 'href="\K.*?(?=/")' | sort -V | tail -n1)
wget -O opera-browser.deb "https://ftp.opera.com/pub/opera/desktop/${LATEST_VERSION}/linux/opera-stable_${LATEST_VERSION}_amd64.deb"

apt install ./opera-browser.deb -y 2>&1 | tee -a "$LOG_FILE"
rm opera-browser.deb
