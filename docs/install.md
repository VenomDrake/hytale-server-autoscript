# Installazione

Sistema consigliato: Ubuntu 24.04 LTS, anche in LXC Proxmox.

```bash
git clone <repo>
cd hytale-server-manager
chmod +x install.sh
sudo ./install.sh
```

Lo script installa Temurin 25 Adoptium:

```bash
apt install wget gpg curl unzip ufw -y
wget -qO - https://packages.adoptium.net/artifactory/api/gpg/key/public | gpg --dearmor -o /usr/share/keyrings/adoptium.gpg
echo "deb [signed-by=/usr/share/keyrings/adoptium.gpg] https://packages.adoptium.net/artifactory/deb noble main" > /etc/apt/sources.list.d/adoptium.list
apt update
apt install temurin-25-jdk -y
java --version
```

Crea l'utente dedicato:

```bash
adduser --disabled-password --gecos "" hytale
mkdir -p /home/hytale/hytale
chown -R hytale:hytale /home/hytale
```

Scarica il downloader ufficiale:

```bash
cd /home/hytale/hytale
curl -L -o hytale-downloader.zip https://downloader.hytale.com/hytale-downloader.zip
unzip hytale-downloader.zip
chmod +x hytale-downloader-linux-amd64
```

Verifiche finali utili:

```bash
java --version
systemctl status hytale-server --no-pager
ss -lunp | grep 5520
sudo -u hytale -H bash -lc 'cd /home/hytale/hytale && ./hytale-downloader-linux-amd64 -print-version'
tail -n 50 /var/log/hytale-autoupdate.log
```
