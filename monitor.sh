#!/usr/bin/env bash
set -euo pipefail
SERVICE_NAME="${SERVICE_NAME:-hytale-server}"
HT_USER="${HT_USER:-hytale}"
HT_HOME="${HT_HOME:-/home/${HT_USER}/hytale}"

echo "== Hytale monitor =="
echo "Servizio: $(systemctl is-active "$SERVICE_NAME" 2>/dev/null || echo sconosciuto)"
echo "Enabled:  $(systemctl is-enabled "$SERVICE_NAME" 2>/dev/null || echo sconosciuto)"
echo
free -h || true
echo
df -h "$HT_HOME" 2>/dev/null || df -h /home 2>/dev/null || true
echo
echo "Processi Java Hytale:"
pgrep -a -f 'HytaleServer.jar|java' || true
echo
echo "Porte UDP 5520:"
ss -lunp | grep ':5520' || true
echo
echo "Ultimi log:"
journalctl -u "$SERVICE_NAME" -n 30 --no-pager 2>/dev/null || true
