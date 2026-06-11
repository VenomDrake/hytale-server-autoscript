#!/usr/bin/env bash
set -euo pipefail

HT_USER="${HT_USER:-hytale}"
HT_HOME="${HT_HOME:-/home/${HT_USER}/hytale}"
REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOWNLOADER_URL="${DOWNLOADER_URL:-https://downloader.hytale.com/hytale-downloader.zip}"
SERVICE_NAME="${SERVICE_NAME:-hytale-server}"
CRON_LINE="0 2 * * * /usr/local/sbin/hytale-autoupdate.sh >> /var/log/hytale-autoupdate.log 2>&1"
TIMEZONE="${TIMEZONE:-Europe/Rome}"

log() { printf '\n[INFO] %s\n' "$*"; }
warn() { printf '\n[WARN] %s\n' "$*"; }
require_root() {
  if [[ "${EUID}" -ne 0 ]]; then
    echo "Esegui con sudo: sudo ./install.sh" >&2
    exit 1
  fi
}
require_cmd() { command -v "$1" >/dev/null 2>&1 || { echo "Comando mancante: $1" >&2; exit 1; }; }

install_java() {
  log "Installazione dipendenze e Temurin 25 Adoptium"
  apt update
  apt install wget gpg curl unzip ufw sudo ca-certificates cron util-linux procps iproute2 tar gzip -y
  wget -qO - https://packages.adoptium.net/artifactory/api/gpg/key/public | gpg --dearmor -o /usr/share/keyrings/adoptium.gpg
  echo "deb [signed-by=/usr/share/keyrings/adoptium.gpg] https://packages.adoptium.net/artifactory/deb noble main" > /etc/apt/sources.list.d/adoptium.list
  apt update
  apt install temurin-25-jdk -y
  java --version
}

create_user() {
  log "Creazione utente dedicato ${HT_USER}"
  if ! id "$HT_USER" >/dev/null 2>&1; then
    adduser --disabled-password --gecos "" "$HT_USER"
  fi
  mkdir -p "$HT_HOME"
  chown -R "${HT_USER}:${HT_USER}" "/home/${HT_USER}"
}

install_downloader_and_server() {
  log "Download Hytale Downloader CLI"
  cd "$HT_HOME"
  curl -L -o hytale-downloader.zip "$DOWNLOADER_URL"
  unzip -o hytale-downloader.zip
  chmod +x hytale-downloader-linux-amd64
  chown -R "${HT_USER}:${HT_USER}" "$HT_HOME"

  log "Controllo versione online"
  sudo -u "$HT_USER" -H bash -lc "cd '$HT_HOME' && ./hytale-downloader-linux-amd64 -print-version" || warn "Controllo versione fallito: potrebbe servire autenticazione o rete."

  log "Download server dedicato ufficiale"
  sudo -u "$HT_USER" -H bash -lc "cd '$HT_HOME' && ./hytale-downloader-linux-amd64"

  latest_zip="$(find "$HT_HOME" -maxdepth 1 -type f -name '*.zip' ! -name 'hytale-downloader.zip' -printf '%T@ %p\n' | sort -nr | head -n 1 | cut -d' ' -f2- || true)"
  if [[ -z "$latest_zip" ]]; then
    echo "Nessuno zip server trovato dopo il download." >&2
    exit 1
  fi

  log "Estraggo ${latest_zip}"
  sudo -u "$HT_USER" -H bash -lc "cd '$HT_HOME' && unzip -o '$latest_zip'"
  [[ -f "${HT_HOME}/start.sh" ]] && chmod +x "${HT_HOME}/start.sh"
  chown -R "${HT_USER}:${HT_USER}" "$HT_HOME"
}

install_config() {
  log "Installazione jvm.options"
  install -o "$HT_USER" -g "$HT_USER" -m 0644 "${REPO_DIR}/config/jvm.options" "${HT_HOME}/jvm.options"
  mkdir -p "${HT_HOME}/logs" "${HT_HOME}/Server"
  chown -R "${HT_USER}:${HT_USER}" "${HT_HOME}/logs" "${HT_HOME}/Server"
}

install_systemd() {
  log "Installazione servizio systemd"
  install -m 0644 "${REPO_DIR}/systemd/hytale-server.service" "/etc/systemd/system/${SERVICE_NAME}.service"
  systemctl daemon-reload
  systemctl enable "$SERVICE_NAME"
}

install_firewall() {
  log "Configurazione firewall UFW UDP 5520"
  ufw allow 5520/udp
  if ufw status | grep -qi inactive; then
    ufw --force enable
  fi
}

install_autoupdate() {
  log "Installazione autoupdate e cron root"
  install -m 0755 "${REPO_DIR}/scripts/hytale-autoupdate.sh" /usr/local/sbin/hytale-autoupdate.sh
  touch /var/log/hytale-autoupdate.log
  chmod 0644 /var/log/hytale-autoupdate.log
  (crontab -l 2>/dev/null | grep -Fv '/usr/local/sbin/hytale-autoupdate.sh' || true; echo "$CRON_LINE") | crontab -
}

set_timezone() {
  log "Impostazione timezone ${TIMEZONE}"
  timedatectl set-timezone "$TIMEZONE" || warn "timedatectl non disponibile nel container; scrivo comunque /etc/timezone."
  echo "$TIMEZONE" > /etc/timezone
}

start_service() {
  log "Avvio servizio ${SERVICE_NAME}"
  systemctl start "$SERVICE_NAME" || warn "Avvio fallito: completa la prima autenticazione OAuth con ./hytale auth-help, poi riprova."
}

final_checks() {
  log "Verifiche finali"
  printf 'Java 25 installato: '; java --version 2>&1 | head -n 1 || true
  printf 'Utente hytale creato: '; id "$HT_USER" >/dev/null 2>&1 && echo OK || echo KO
  printf 'Downloader presente: '; [[ -x "${HT_HOME}/hytale-downloader-linux-amd64" ]] && echo OK || echo KO
  printf 'Assets.zip presente: '; [[ -f "${HT_HOME}/Assets.zip" ]] && echo OK || echo KO
  printf 'Server/HytaleServer.jar presente: '; [[ -f "${HT_HOME}/Server/HytaleServer.jar" ]] && echo OK || echo KO
  printf 'start.sh eseguibile: '; [[ -x "${HT_HOME}/start.sh" ]] && echo OK || echo KO
  printf 'systemd enabled: '; systemctl is-enabled "$SERVICE_NAME" 2>/dev/null || true
  printf 'systemd active: '; systemctl is-active "$SERVICE_NAME" 2>/dev/null || true
  printf 'porta UDP 5520 in ascolto: '; ss -lunp | grep -q ':5520' && echo OK || echo 'non ancora in ascolto'
  printf 'jvm.options presente: '; [[ -f "${HT_HOME}/jvm.options" ]] && echo OK || echo KO
  printf 'autoupdate installato: '; [[ -x /usr/local/sbin/hytale-autoupdate.sh ]] && echo OK || echo KO
  printf 'cron configurato: '; crontab -l 2>/dev/null | grep -q '/usr/local/sbin/hytale-autoupdate.sh' && echo OK || echo KO
  printf 'timezone corretta: '; timedatectl 2>/dev/null | grep -q "$TIMEZONE" && echo OK || cat /etc/timezone
}

main() {
  require_root
  require_cmd apt
  install_java
  create_user
  install_downloader_and_server
  install_config
  install_systemd
  install_firewall
  install_autoupdate
  set_timezone
  start_service
  final_checks
  cat <<MSG

Installazione completata.
Se il servizio non parte perché manca l'autenticazione, esegui:
  ./hytale auth-help
MSG
}

main "$@"
