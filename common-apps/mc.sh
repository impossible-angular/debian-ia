#!/bin/bash
set -euo pipefail

echoG "==========================Midnight Commander================================"

apt-get install -y -qq mc 2>&1 | tee -a "${LOG_FILE}"
