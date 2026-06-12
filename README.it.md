# Hytale Server Manager

Lingua:
- Italiano, corrente
- English, [README.md](README.md)

![Ubuntu 24.04](https://img.shields.io/badge/Ubuntu-24.04-E95420?logo=ubuntu&logoColor=white)
![Java 25](https://img.shields.io/badge/Java-25-007396?logo=openjdk&logoColor=white)
![Systemd](https://img.shields.io/badge/Systemd-service-3A3A3A?logo=linux&logoColor=white)
![Shell scripts](https://img.shields.io/badge/Shell-scripts-4EAA25?logo=gnubash&logoColor=white)
![License MIT](https://img.shields.io/badge/License-MIT-blue.svg)

Toolkit in stile LinuxGSM per installare, configurare, aggiornare e gestire un server dedicato Hytale su Linux, con focus su Ubuntu 24.04 LTS e container LXC Proxmox.

> Disclaimer: questa repository non include file proprietari Hytale, zip del server, token, `auth.enc` o credenziali OAuth. Gli script scaricano i file ufficiali tramite Hytale Downloader CLI. Serve un account Hytale valido.

## Funzionalità

| Funzionalità | Inclusa |
| --- | --- |
| Auto install | Sì |
| Auto update | Sì |
| Manual update | Sì |
| Backup | Sì |
| Restore | Sì |
| Systemd service | Sì |
| UFW firewall | Sì |
| OAuth device login | Documentato |
| Encrypted credential persistence | Documentato |
| Proxmox LXC support | Documentato |
| Healthcheck | Sì |
| Monitoring | Sì |
| GC tuning | Sì |
| Troubleshooting docs | Sì |

## Panoramica
- Installazione Temurin 25 Adoptium.
- Utente dedicato `hytale` e directory `/home/hytale/hytale`.
- Download del server da `https://downloader.hytale.com/hytale-downloader.zip`.
- Servizio `systemd` con avvio automatico e restart automatico.
- Firewall UFW con porta Hytale QUIC `UDP 5520`.
- `jvm.options` ottimizzato per circa 7 player reali su LXC 8 core / 32 GB RAM.
- Backup manuali tar.gz e supporto ai backup integrati del server.
- Autoupdate giornaliero via cron root con log separato.
- Wrapper `./hytale` per gestione quotidiana.

## Requisiti consigliati

| Componente | Minimo consigliato | Ideale server piccolo |
| --- | --- | --- |
| OS | Ubuntu 24.04 LTS | Ubuntu 24.04 LTS LXC Proxmox |
| CPU | 4 core | 8 core |
| RAM | 16 GB | 32 GB |
| Disco | 80 GB | 120 GB o più |
| Java | Temurin 25 | Temurin 25 JDK |
| Porta | UDP 5520 | UDP 5520 |

## Quick start

```bash
# Sostituisci questo valore con il tuo fork o con l'URL della repository ufficiale.
REPO_URL="https://github.com/YOUR-USERNAME/hytale-server-manager.git"
git clone "$REPO_URL"
cd hytale-server-manager
chmod +x install.sh
sudo ./install.sh
```

## Comandi disponibili

```bash
./hytale start
./hytale stop
./hytale restart
./hytale status
./hytale logs
./hytale console
./hytale update
./hytale backup
./hytale restore /home/hytale/backups/manual/hytale-backup-YYYYmmdd-HHMMSS.tar.gz
./hytale monitor
./hytale healthcheck
./hytale version
./hytale ports
./hytale auth-help
```

## Installazione guidata

`install.sh` esegue queste operazioni:

1. Installa dipendenze base, `ufw`, `cron`, `sudo`, `curl`, `unzip`, `iproute2` e Temurin 25.
2. Crea l'utente dedicato `hytale`.
3. Scarica ed estrae Hytale Downloader CLI.
4. Esegue il downloader come utente `hytale`.
5. Estrae lo zip server generato e ripristina il bit eseguibile di `start.sh`.
6. Copia `config/jvm.options` in `/home/hytale/hytale/jvm.options`.
7. Installa `/etc/systemd/system/hytale-server.service`.
8. Apre `UDP 5520` con UFW.
9. Installa `/usr/local/sbin/hytale-autoupdate.sh` e cron giornaliero alle 02:00.
10. Imposta timezone `Europe/Rome`.
11. Avvia il servizio e stampa le verifiche finali.

## Prima autenticazione OAuth

Il server richiede una prima autenticazione manuale:

```bash
sudo systemctl stop hytale-server
sudo -u hytale -H bash -lc 'cd /home/hytale/hytale && ./start.sh'
```

Dentro la console Hytale:

```text
/auth login device
/auth persistence Encrypted
/auth status
```

Stato atteso:

```text
Session Token: Present
Identity Token: Present
Credentials saved using: Encrypted
```

Poi:

```text
/stop
```

E riavvia il servizio:

```bash
sudo systemctl start hytale-server
```

## Update manuale e automatico

Update manuale:

```bash
./hytale update
```

Cron automatico root installato:

```cron
0 2 * * * /usr/local/sbin/hytale-autoupdate.sh >> /var/log/hytale-autoupdate.log 2>&1
```

Log update:

```bash
tail -n 50 /var/log/hytale-autoupdate.log
```

Lo script usa `flock`, ferma il servizio, confronta versione installata e online, scarica solo se serve, estrae con overwrite, ripristina `chmod +x start.sh`, corregge ownership e riavvia il servizio.

## Backup e restore

Hytale può essere avviato con backup integrati `--backup --backup-dir backups --backup-frequency 30`, con salvataggi ogni 30 minuti in `Server/backups`.

Backup manuale del manager:

```bash
./hytale backup
```

Include, se presenti:

- `/home/hytale/hytale/Server/config.json`
- `/home/hytale/hytale/Server/permissions.json`
- `/home/hytale/hytale/Server/whitelist.json`
- `/home/hytale/hytale/Server/bans.json`
- `/home/hytale/hytale/Server/universe`
- `/home/hytale/hytale/Server/backups`

Esclude token e credenziali: `auth.enc`, `.hytale-downloader-credentials.json*`.

Restore:

```bash
./hytale restore /home/hytale/backups/manual/hytale-backup-YYYYmmdd-HHMMSS.tar.gz
```

## Firewall e porte

Hytale usa QUIC su UDP, non TCP.

```bash
sudo ufw allow 5520/udp
sudo ufw enable
ss -lunp | grep 5520
```

## Proxmox LXC notes

Consigli rapidi:

- Template Ubuntu 24.04 LTS.
- 8 core e 32 GB RAM se vuoi usare il profilo JVM incluso.
- Disco almeno 80 GB, meglio 120 GB o più.
- Container con nesting/keyctl se richiesto dalla tua policy Proxmox.
- Se `timedatectl` non funziona nel container, imposta timezone dal nodo Proxmox o verifica `/etc/timezone`.
- Apri/forwarda UDP 5520 anche su firewall Proxmox, router e cloud provider.

## Troubleshooting rapido

### `status=203/EXEC`

Causa più comune: `start.sh` non è eseguibile.

```bash
sudo chmod +x /home/hytale/hytale/start.sh
sudo systemctl restart hytale-server
```

### `No server tokens configured`

Auth assente o scaduta. Rifai login manuale:

```text
/auth login device
/auth persistence Encrypted
```

### `invalid_grant` o `refresh token expired`

Token OAuth scaduto o revocato. Rifai login manuale da console interattiva.

### Downloader: `unexpected end of JSON input`

Credenziali downloader corrotte:

```bash
sudo rm -f /home/hytale/hytale/.hytale-downloader-credentials.json*
sudo -u hytale -H bash -lc 'cd /home/hytale/hytale && ./hytale-downloader-linux-amd64 -print-version'
```

### `Skipping pack at Hytale_Shop: missing or invalid manifest.json`

Dentro `Server/mods` c'è una cartella non valida come mod:

```bash
sudo mkdir -p /home/hytale/hytale/Server/data
sudo mv /home/hytale/hytale/Server/mods/Hytale_Shop /home/hytale/hytale/Server/data/
```

## Verifiche post-installazione

```bash
java --version
systemctl status hytale-server --no-pager
ss -lunp | grep 5520
sudo -u hytale -H bash -lc 'cd /home/hytale/hytale && ./hytale-downloader-linux-amd64 -print-version'
tail -n 50 /var/log/hytale-autoupdate.log
```

## Documentazione

- [Installazione](docs/install.md)
- [Prima autenticazione](docs/first-auth.md)
- [Update](docs/update.md)
- [Backup](docs/backup.md)
- [Restore](docs/restore.md)
- [OP e permessi](docs/op-and-permissions.md)
- [Whitelist](docs/whitelist.md)
- [Troubleshooting](docs/troubleshooting.md)
- [Proxmox LXC](docs/proxmox-lxc.md)
- [Roadmap](docs/roadmap.md)
- [Changelog](CHANGELOG.md)
- [Checklist release](RELEASE.md)

## FAQ

**Posso committare il server scaricato?** No. Zip, `Server/`, `Assets.zip`, `auth.enc` e credenziali sono esclusi e non vanno pubblicati.

**La porta è TCP o UDP?** UDP 5520.

**Perché l'installazione può fermarsi al downloader?** Il downloader/server può richiedere rete e autenticazione valida. Completa i passaggi OAuth manuali se richiesto.

**Posso cambiare RAM JVM?** Sì, modifica `/home/hytale/hytale/jvm.options` o `config/jvm.options` prima dell'installazione.


## Licenza

Rilasciato con [licenza MIT](LICENSE).
