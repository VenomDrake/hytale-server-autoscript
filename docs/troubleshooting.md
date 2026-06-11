# Troubleshooting

## `status=203/EXEC`

Causa più comune: `start.sh` non eseguibile.

```bash
sudo chmod +x /home/hytale/hytale/start.sh
sudo systemctl restart hytale-server
```

## `No server tokens configured`

Auth assente o scaduta.

```text
/auth login device
/auth persistence Encrypted
```

## `invalid_grant` o `refresh token expired`

Token OAuth scaduto o revocato. Rifai login manuale da console interattiva.

## Downloader: `unexpected end of JSON input`

Credenziali downloader corrotte.

```bash
sudo rm -f /home/hytale/hytale/.hytale-downloader-credentials.json*
sudo -u hytale -H bash -lc 'cd /home/hytale/hytale && ./hytale-downloader-linux-amd64 -print-version'
```

## `Skipping pack at Hytale_Shop: missing or invalid manifest.json`

Cartella non valida dentro `Server/mods`.

```bash
sudo mkdir -p /home/hytale/hytale/Server/data
sudo mv /home/hytale/hytale/Server/mods/Hytale_Shop /home/hytale/hytale/Server/data/
```
