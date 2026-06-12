#!/usr/bin/env bash
set -euo pipefail
if [[ "${EUID}" -eq 0 ]]; then
  /usr/local/sbin/hytale-autoupdate.sh
else
  sudo /usr/local/sbin/hytale-autoupdate.sh
fi
