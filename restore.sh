#!/usr/bin/env bash
set -euo pipefail

HT_USER="${HT_USER:-hytale}"
HT_HOME="${HT_HOME:-/home/${HT_USER}/hytale}"
SERVICE_NAME="${SERVICE_NAME:-hytale-server}"

usage() {
  cat <<USAGE
Uso: sudo ./restore.sh /percorso/hytale-backup-YYYYmmdd-HHMMSS.tar.gz

Il restore ferma hytale-server, estrae il backup in / e ripristina proprietà hytale:hytale.
USAGE
}

main() {
  if [[ "${1:-}" == "-h" || "${1:-}" == "--help" || -z "${1:-}" ]]; then
    usage
    exit 0
  fi
  if [[ "${EUID}" -ne 0 ]]; then
    echo "Questo comando richiede sudo/root." >&2
    exit 1
  fi

  archive="$1"
  if [[ ! -f "$archive" ]]; then
    echo "Archivio non trovato: $archive" >&2
    exit 1
  fi

  echo "Fermo ${SERVICE_NAME}"
  systemctl stop "$SERVICE_NAME" || true
  echo "Estraggo ${archive}"
  tar -xzf "$archive" -C /
  chown -R "${HT_USER}:${HT_USER}" "$HT_HOME"
  [[ -f "${HT_HOME}/start.sh" ]] && chmod +x "${HT_HOME}/start.sh"
  echo "Riavvio ${SERVICE_NAME}"
  systemctl start "$SERVICE_NAME"
  echo "Restore completato."
}

main "$@"
