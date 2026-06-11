#!/usr/bin/env bash
set -euo pipefail

HT_USER="${HT_USER:-hytale}"
HT_HOME="${HT_HOME:-/home/${HT_USER}/hytale}"
BACKUP_ROOT="${BACKUP_ROOT:-/home/${HT_USER}/backups/manual}"
SERVICE_NAME="${SERVICE_NAME:-hytale-server}"
STAMP="$(date '+%Y%m%d-%H%M%S')"
ARCHIVE="${BACKUP_ROOT}/hytale-backup-${STAMP}.tar.gz"

require_root_or_sudo() {
  if [[ "${EUID}" -ne 0 ]]; then
    echo "Questo comando richiede sudo/root per leggere tutti i file del server." >&2
    exit 1
  fi
}

main() {
  require_root_or_sudo
  mkdir -p "$BACKUP_ROOT"
  chown -R "${HT_USER}:${HT_USER}" "$(dirname "$BACKUP_ROOT")" || true

  mapfile -t existing_paths < <(
    for path in \
      "${HT_HOME}/Server/config.json" \
      "${HT_HOME}/Server/permissions.json" \
      "${HT_HOME}/Server/whitelist.json" \
      "${HT_HOME}/Server/bans.json" \
      "${HT_HOME}/Server/universe" \
      "${HT_HOME}/Server/backups"; do
      [[ -e "$path" ]] && printf '%s\n' "$path"
    done
  )

  if [[ "${#existing_paths[@]}" -eq 0 ]]; then
    echo "Nessun file da salvare trovato in ${HT_HOME}/Server" >&2
    exit 1
  fi

  echo "Creo backup manuale: ${ARCHIVE}"
  systemctl is-active --quiet "$SERVICE_NAME" && echo "Nota: il server è attivo; i backup integrati Hytale riducono il rischio di snapshot incoerenti."
  tar --exclude='auth.enc' \
      --exclude='.hytale-downloader-credentials.json' \
      --exclude='.hytale-downloader-credentials.json*' \
      -czf "$ARCHIVE" "${existing_paths[@]}"
  chown "${HT_USER}:${HT_USER}" "$ARCHIVE" || true
  echo "Backup creato: ${ARCHIVE}"
}

main "$@"
