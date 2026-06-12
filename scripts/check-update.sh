#!/usr/bin/env bash
set -euo pipefail
HT_USER="${HT_USER:-hytale}"
HT_HOME="${HT_HOME:-/home/${HT_USER}/hytale}"
DL_BIN="${DL_BIN:-${HT_HOME}/hytale-downloader-linux-amd64}"
SERVICE_NAME="${SERVICE_NAME:-hytale-server}"
installed="$(journalctl -u "$SERVICE_NAME" -b --no-pager 2>/dev/null | grep -i 'Booting up HytaleServer - Version:' | tail -n 1 | sed -n 's/.*Version: \([^,]*\).*/\1/p' || true)"
online="$(timeout 45s sudo -u "$HT_USER" -H bash -lc "cd '$HT_HOME' && '$DL_BIN' -print-version" 2>/dev/null | tail -n 1 || true)"
echo "Installata: ${installed:-sconosciuta}"
echo "Online:     ${online:-sconosciuta}"
if [[ -n "$installed" && -n "$online" && "$installed" == "$online" ]]; then
  echo "Aggiornato"
else
  echo "Aggiornamento disponibile o versione non determinabile"
fi
