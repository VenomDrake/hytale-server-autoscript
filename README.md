# Hytale Server Manager

Language:
- English, current
- Italian, [README.it.md](README.it.md)

![Ubuntu 24.04](https://img.shields.io/badge/Ubuntu-24.04-E95420?logo=ubuntu&logoColor=white)
![Java 25](https://img.shields.io/badge/Java-25-007396?logo=openjdk&logoColor=white)
![Systemd](https://img.shields.io/badge/Systemd-service-3A3A3A?logo=linux&logoColor=white)
![Shell scripts](https://img.shields.io/badge/Shell-scripts-4EAA25?logo=gnubash&logoColor=white)
![License MIT](https://img.shields.io/badge/License-MIT-blue.svg)

A LinuxGSM-style toolkit to install, configure, update, and manage a dedicated Hytale server on Linux, focused on Ubuntu 24.04 LTS and Proxmox LXC containers.

> Disclaimer: this repository does not include proprietary Hytale files, server ZIP files, tokens, `auth.enc`, or OAuth credentials. The scripts download official files through the official Hytale Downloader CLI. A valid Hytale account is required.

## Features

| Feature | Included |
| --- | --- |
| Auto install | Yes |
| Auto update | Yes |
| Manual update | Yes |
| Backup | Yes |
| Restore | Yes |
| Systemd service | Yes |
| UFW firewall | Yes |
| OAuth device login | Documented |
| Encrypted credential persistence | Documented |
| Proxmox LXC support | Documented |
| Healthcheck | Yes |
| Monitoring | Yes |
| GC tuning | Yes |
| Troubleshooting docs | Yes |

## Overview

- Temurin 25 Adoptium installation.
- Dedicated `hytale` user and `/home/hytale/hytale` directory.
- Server download from `https://downloader.hytale.com/hytale-downloader.zip`.
- `systemd` service with automatic startup and automatic restart.
- UFW firewall rule for the Hytale QUIC port, `UDP 5520`.
- `jvm.options` tuned for roughly 7 real players on an 8-core / 32 GB RAM LXC container.
- Manual tar.gz backups and support for Hytale's built-in server backups.
- Daily autoupdate through root cron with a dedicated update log.
- `./hytale` wrapper for day-to-day operations.

## Recommended requirements

| Component | Recommended minimum | Ideal small server |
| --- | --- | --- |
| OS | Ubuntu 24.04 LTS | Ubuntu 24.04 LTS Proxmox LXC |
| CPU | 4 cores | 8 cores |
| RAM | 16 GB | 32 GB |
| Disk | 80 GB | 120 GB or more |
| Java | Temurin 25 | Temurin 25 JDK |
| Port | UDP 5520 | UDP 5520 |

## Quick start

```bash
# Replace this value with your fork or the official repository URL.
REPO_URL="https://github.com/YOUR-USERNAME/hytale-server-manager.git"
git clone "$REPO_URL"
cd hytale-server-manager
chmod +x install.sh
sudo ./install.sh
```

## Available commands

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

## Guided installation

`install.sh` performs these steps:

1. Installs base dependencies, `ufw`, `cron`, `sudo`, `curl`, `unzip`, `iproute2`, and Temurin 25.
2. Creates the dedicated `hytale` user.
3. Downloads and extracts the Hytale Downloader CLI.
4. Runs the downloader as the `hytale` user.
5. Extracts the generated server ZIP and restores the executable bit on `start.sh`.
6. Copies `config/jvm.options` to `/home/hytale/hytale/jvm.options`.
7. Installs `/etc/systemd/system/hytale-server.service`.
8. Opens `UDP 5520` with UFW.
9. Installs `/usr/local/sbin/hytale-autoupdate.sh` and a daily 02:00 cron entry.
10. Sets the timezone to `Europe/Rome`.
11. Starts the service and prints final checks.

## First OAuth authentication

The server requires a first manual authentication:

```bash
sudo systemctl stop hytale-server
sudo -u hytale -H bash -lc 'cd /home/hytale/hytale && ./start.sh'
```

Inside the Hytale console:

```text
/auth login device
/auth persistence Encrypted
/auth status
```

Expected status:

```text
Session Token: Present
Identity Token: Present
Credentials saved using: Encrypted
```

Then stop the server from the console:

```text
/stop
```

And restart the service:

```bash
sudo systemctl start hytale-server
```

## Manual and automatic updates

Manual update:

```bash
./hytale update
```

Installed root cron entry:

```cron
0 2 * * * /usr/local/sbin/hytale-autoupdate.sh >> /var/log/hytale-autoupdate.log 2>&1
```

Update log:

```bash
tail -n 50 /var/log/hytale-autoupdate.log
```

The script uses `flock`, stops the service, compares installed and online versions, downloads only when needed, extracts with overwrite, restores `chmod +x start.sh`, fixes ownership, and restarts the service.

## Backup and restore

Hytale can be started with built-in backups using `--backup --backup-dir backups --backup-frequency 30`, creating saves every 30 minutes in `Server/backups`.

Manual manager backup:

```bash
./hytale backup
```

Includes, when present:

- `/home/hytale/hytale/Server/config.json`
- `/home/hytale/hytale/Server/permissions.json`
- `/home/hytale/hytale/Server/whitelist.json`
- `/home/hytale/hytale/Server/bans.json`
- `/home/hytale/hytale/Server/universe`
- `/home/hytale/hytale/Server/backups`

Excludes tokens and credentials: `auth.enc`, `.hytale-downloader-credentials.json*`.

Restore:

```bash
./hytale restore /home/hytale/backups/manual/hytale-backup-YYYYmmdd-HHMMSS.tar.gz
```

## Firewall and ports

Hytale uses QUIC over UDP, not TCP.

```bash
sudo ufw allow 5520/udp
sudo ufw enable
ss -lunp | grep 5520
```

## Proxmox LXC notes

Quick recommendations:

- Ubuntu 24.04 LTS template.
- 8 cores and 32 GB RAM if you want to use the included JVM profile.
- At least 80 GB disk, preferably 120 GB or more.
- Enable nesting/keyctl if required by your Proxmox policy.
- If `timedatectl` does not work in the container, set the timezone from the Proxmox node or verify `/etc/timezone`.
- Open/forward UDP 5520 on the Proxmox firewall, router, and cloud provider too.

## Troubleshooting quick reference

### `status=203/EXEC`

Most common cause: `start.sh` is not executable.

```bash
sudo chmod +x /home/hytale/hytale/start.sh
sudo systemctl restart hytale-server
```

### `No server tokens configured`

Authentication is missing or expired. Perform manual login again:

```text
/auth login device
/auth persistence Encrypted
```

### `invalid_grant` or `refresh token expired`

The OAuth token is expired or revoked. Repeat manual login from an interactive console.

### Downloader: `unexpected end of JSON input`

Downloader credentials are corrupted:

```bash
sudo rm -f /home/hytale/hytale/.hytale-downloader-credentials.json*
sudo -u hytale -H bash -lc 'cd /home/hytale/hytale && ./hytale-downloader-linux-amd64 -print-version'
```

### `Skipping pack at Hytale_Shop: missing or invalid manifest.json`

There is an invalid mod-like folder inside `Server/mods`:

```bash
sudo mkdir -p /home/hytale/hytale/Server/data
sudo mv /home/hytale/hytale/Server/mods/Hytale_Shop /home/hytale/hytale/Server/data/
```

## Post-installation checks

```bash
java --version
systemctl status hytale-server --no-pager
ss -lunp | grep 5520
sudo -u hytale -H bash -lc 'cd /home/hytale/hytale && ./hytale-downloader-linux-amd64 -print-version'
tail -n 50 /var/log/hytale-autoupdate.log
```

## Documentation

The current docs are written in Italian. English docs are planned.

- [Installation](docs/install.md)
- [First authentication](docs/first-auth.md)
- [Update](docs/update.md)
- [Backup](docs/backup.md)
- [Restore](docs/restore.md)
- [OP and permissions](docs/op-and-permissions.md)
- [Whitelist](docs/whitelist.md)
- [Troubleshooting](docs/troubleshooting.md)
- [Proxmox LXC](docs/proxmox-lxc.md)
- [Roadmap](docs/roadmap.md)
- [Changelog](CHANGELOG.md)
- [Release checklist](RELEASE.md)

## FAQ

**Can I commit the downloaded server?** No. ZIP files, `Server/`, `Assets.zip`, `auth.enc`, and credentials are excluded and must not be published.

**Is the port TCP or UDP?** UDP 5520.

**Why can installation stop at the downloader step?** The downloader/server may require network access and valid authentication. Complete the manual OAuth steps if requested.

**Can I change JVM RAM?** Yes, edit `/home/hytale/hytale/jvm.options` or `config/jvm.options` before installation.


## License

Released under the [MIT License](LICENSE).
