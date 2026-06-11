#!/usr/bin/env bash
set -euo pipefail

TS() { date '+%F %T'; }

HT_USER="${HT_USER:-hytale}"
HT_HOME="${HT_HOME:-/home/${HT_USER}/hytale}"
DL_BIN="${DL_BIN:-${HT_HOME}/hytale-downloader-linux-amd64}"
ZIP_DIR="${ZIP_DIR:-${HT_HOME}}"
SERVICE_NAME="${SERVICE_NAME:-hytale-server}"
LOG_FILE="${LOG_FILE:-/var/log/hytale-autoupdate.log}"
LOCK_FILE="${LOCK_FILE:-/var/lock/hytale-autoupdate.lock}"

log() {
  printf '%s %s\n' "$(TS)" "$*" | tee -a "$LOG_FILE"
}

require_cmd() {
  command -v "$1" >/dev/null 2>&1 || { log "ERRORE: comando mancante: $1"; exit 1; }
}

run_as_hytale() {
  sudo -u "$HT_USER" -H bash -lc "$1"
}

extract_installed_version() {
  journalctl -u "$SERVICE_NAME" -b --no-pager 2>/dev/null \
    | grep -i 'Booting up HytaleServer - Version:' \
    | tail -n 1 \
    | sed -n 's/.*Version: \([^,]*\).*/\1/p' \
    || true
}

extract_online_version() {
  timeout 45s sudo -u "$HT_USER" -H bash -lc "cd '$HT_HOME' && '$DL_BIN' -print-version" 2>/dev/null \
    | tail -n 1 \
    || true
}

main() {
  require_cmd systemctl
  require_cmd journalctl
  require_cmd unzip
  require_cmd grep
  require_cmd sed
  require_cmd timeout
  require_cmd flock
  require_cmd tee
  require_cmd sudo

  touch "$LOG_FILE"
  chmod 0644 "$LOG_FILE" || true

  exec 9>"$LOCK_FILE"
  if ! flock -n 9; then
    log "Update già in esecuzione, esco"
    exit 0
  fi

  if [[ ! -x "$DL_BIN" ]]; then
    log "ERRORE: downloader non trovato o non eseguibile: $DL_BIN"
    exit 1
  fi

  log "Stop servizio ${SERVICE_NAME}"
  systemctl stop "$SERVICE_NAME" || true

  INSTALLED_VER="$(extract_installed_version)"
  ONLINE_VER="$(extract_online_version)"

  log "Versione installata: ${INSTALLED_VER:-sconosciuta}"
  log "Versione online: ${ONLINE_VER:-sconosciuta}"

  if [[ -z "${ONLINE_VER}" ]]; then
    log "ERRORE: impossibile leggere la versione online"
    log "Avvio servizio ${SERVICE_NAME} e termino"
    systemctl start "$SERVICE_NAME" || true
    exit 1
  fi

  if [[ -n "${INSTALLED_VER}" && "${ONLINE_VER}" == "${INSTALLED_VER}" ]]; then
    log "Nessun aggiornamento richiesto"
    log "Avvio servizio ${SERVICE_NAME}"
    systemctl start "$SERVICE_NAME"
    exit 0
  fi

  log "Aggiornamento richiesto, scarico nuova versione"
  cd "$ZIP_DIR"

  timeout 3600s sudo -u "$HT_USER" -H bash -lc "cd '$HT_HOME' && '$DL_BIN'" >/dev/null 2>&1

  LATEST_ZIP="$(find "$ZIP_DIR" -maxdepth 1 -type f -name '*.zip' -printf '%T@ %p\n' 2>/dev/null | sort -nr | head -n 1 | cut -d' ' -f2- || true)"
  if [[ -z "${LATEST_ZIP}" ]]; then
    log "ERRORE: zip non trovato"
    log "Avvio servizio ${SERVICE_NAME}"
    systemctl start "$SERVICE_NAME" || true
    exit 1
  fi

  log "File scaricato: ${LATEST_ZIP}"
  log "Unzip in corso"
  run_as_hytale "cd '$HT_HOME' && unzip -o '${LATEST_ZIP}'" >/dev/null

  chmod +x "${HT_HOME}/start.sh"
  chown -R "${HT_USER}:${HT_USER}" "$HT_HOME"

  log "Avvio servizio ${SERVICE_NAME}"
  systemctl start "$SERVICE_NAME"

  log "Fine"
}

main "$@"
