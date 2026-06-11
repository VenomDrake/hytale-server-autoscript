#!/usr/bin/env bash
set -euo pipefail
sudo systemctl stop hytale-server || true
sudo -u hytale -H bash -lc 'cd /home/hytale/hytale && ./start.sh'
