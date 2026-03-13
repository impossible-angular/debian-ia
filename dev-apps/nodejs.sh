#!/bin/bash

set -euo pipefail

BASE_URL="https://nodejs.org/dist"
ARCH="linux-x64"
INSTALL_DIR="/usr/local"

echo "Detecting latest Node.js LTS..."

VERSION=$(curl -fsSL $BASE_URL/index.json | jq -r '[.[] | select(.lts != false)][0].version')
FILE="node-$VERSION-$ARCH.tar.xz"
SHAFILE="SHASUMS256.txt"

echo "Latest LTS: [$VERSION]"
echo "Downloading: [$FILE]"

curl -O $BASE_URL/$VERSION/$FILE
curl -O $BASE_URL/$VERSION/$SHAFILE

echo "Verifying checksum..."
grep "$FILE" $SHAFILE | sha256sum -c -
echo "Checksum verified ✔"

echo "Removing previous Node.js install (if exists)..."
sudo rm -rf \
  $INSTALL_DIR/bin/node \
  $INSTALL_DIR/bin/npm \
  $INSTALL_DIR/bin/npx \
  $INSTALL_DIR/include/node \
  $INSTALL_DIR/lib/node_modules \
  $INSTALL_DIR/share/doc/node \
  $INSTALL_DIR/share/systemtap/tapset/node.stp 2>/dev/null || true

echo "Extracting..."
tar -xJf $FILE

echo "Installing to $INSTALL_DIR..."
tar -xJf $FILE -C $INSTALL_DIR --strip-components=1

echo "Cleaning up..."
rm -rf node-$VERSION-$ARCH
rm $FILE
rm $SHAFILE

echo "Installation complete 🎉"
echo -n "node -v: "; node -v
echo -n "npm -v: "; npm -v