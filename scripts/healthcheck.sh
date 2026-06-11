#!/usr/bin/env bash
set -euo pipefail
SERVICE_NAME="${SERVICE_NAME:-hytale-server}"
HT_USER="${HT_USER:-hytale}"
HT_HOME="${HT_HOME:-/home/${HT_USER}/hytale}"
DL_BIN="${DL_BIN:-${HT_HOME}/hytale-downloader-linux-amd64}"

ok=0
check() {
  label="$1"; shift
  if "$@" >/dev/null 2>&1; then
    printf '[OK] %s\n' "$label"
  else
    printf '[KO] %s\n' "$label"
    ok=1
  fi
}

check "systemd active" systemctl is-active --quiet "$SERVICE_NAME"
check "systemd enabled" systemctl is-enabled --quiet "$SERVICE_NAME"
check "porta UDP 5520" bash -lc "ss -lunp | grep -q ':5520'"
check "processo java" pgrep -f 'HytaleServer.jar|java'
check "Server/HytaleServer.jar" test -f "${HT_HOME}/Server/HytaleServer.jar"
check "start.sh eseguibile" test -x "${HT_HOME}/start.sh"
check "jvm.options" test -f "${HT_HOME}/jvm.options"

echo
echo "Memoria:"
free -h || true

echo
echo "Versione installata:"
journalctl -u "$SERVICE_NAME" -b --no-pager 2>/dev/null | grep -i 'Booting up HytaleServer - Version:' | tail -n 1 || true

echo
echo "Versione online:"
if [[ -x "$DL_BIN" ]]; then
  timeout 45s sudo -u "$HT_USER" -H bash -lc "cd '$HT_HOME' && '$DL_BIN' -print-version" 2>/dev/null | tail -n 1 || true
else
  echo "Downloader non trovato: $DL_BIN"
fi

exit "$ok"
