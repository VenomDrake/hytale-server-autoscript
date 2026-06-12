# Backup

> This documentation is currently written in Italian. English docs are planned.


Il server può gestire backup integrati con:

```text
--backup --backup-dir backups --backup-frequency 30
```

Il manager include anche backup manuale:

```bash
./hytale backup
```

Percorso default:

```text
/home/hytale/backups/manual/hytale-backup-YYYYmmdd-HHMMSS.tar.gz
```

Sono inclusi, se presenti, `config.json`, `permissions.json`, `whitelist.json`, `bans.json`, `Server/universe` e `Server/backups`.

Sono esclusi `auth.enc` e `.hytale-downloader-credentials.json*`.
