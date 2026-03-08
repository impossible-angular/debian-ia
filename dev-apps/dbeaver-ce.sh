#!/bin/bash

echo -e "${GREEN}========================== dbeaver ==============================${NC}"

wget -q -O - https://dbeaver.io/debs/dbeaver.gpg.key | gpg --dearmor -o /usr/share/keyrings/dbeaver.gpg.key
echo "deb [signed-by=/usr/share/keyrings/dbeaver.gpg.key] https://dbeaver.io/debs/dbeaver-ce /" | tee /etc/apt/sources.list.d/dbeaver.list
apt-get update
apt-get install -y -qq dbeaver-ce  2>&1 | tee -a "$LOG_FILE"
