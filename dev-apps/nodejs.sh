#!/bin/bash
set -euo pipefail

echo -e "${GREEN}========================== LTS Node JS ==============================${NC}"

BASE_URL="https://nodejs.org/dist"
ARCH="linux-x64"
INSTALL_DIR="/usr/local"

echo -e "${GREEN} Detecting latest Node.js LTS...${NC}"

VERSION=$(curl -fsSL $BASE_URL/index.json | jq -r '[.[] | select(.lts != false)][0].version')
FILE="node-$VERSION-$ARCH.tar.xz"
SHAFILE="SHASUMS256.txt"

echo -e "${GREEN} Latest LTS: [$VERSION] ${NC}"
echo -e "${GREEN} Downloading: [$FILE] ${NC}"

curl -O $BASE_URL/$VERSION/$FILE
curl -O $BASE_URL/$VERSION/$SHAFILE

echo -e "${GREEN} Verifying checksum...${NC}"
grep "$FILE" $SHAFILE | sha256sum -c -
echo -e "${GREEN} Checksum verified ✔${NC}"

echo -e "${GREEN} Removing previous Node.js install (if exists)...${NC}"
sudo rm -rf \
  $INSTALL_DIR/bin/node \
  $INSTALL_DIR/bin/npm \
  $INSTALL_DIR/bin/npx \
  $INSTALL_DIR/include/node \
  $INSTALL_DIR/lib/node_modules \
  $INSTALL_DIR/share/doc/node \
  $INSTALL_DIR/share/systemtap/tapset/node.stp 2>/dev/null || true

echo -e "${GREEN} Extracting...${NC}"
tar -xJf $FILE

echo -e "${GREEN} Installing to $INSTALL_DIR...${NC}"
tar -xJf $FILE -C $INSTALL_DIR --strip-components=1

echo -e "${GREEN} Cleaning up...${NC}"
rm -rf node-$VERSION-$ARCH
rm $FILE
rm $SHAFILE

echo -e "${GREEN}=========================== Installation complete 🎉 =============================="
echo -en " node -v: "; node -v;
echo -en " npm -v: "; npm -v;
echo -en "${NC}"