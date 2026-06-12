# Restore

> This documentation is currently written in Italian. English docs are planned.


Ripristina un backup manuale:

```bash
./hytale restore /home/hytale/backups/manual/hytale-backup-YYYYmmdd-HHMMSS.tar.gz
```

Il restore ferma `hytale-server`, estrae l'archivio in `/`, ripristina proprietà `hytale:hytale`, rende `start.sh` eseguibile e riavvia il servizio.
