# Update

Update manuale:

```bash
./hytale update
```

Script installato:

```bash
/usr/local/sbin/hytale-autoupdate.sh
```

Cron root:

```cron
0 2 * * * /usr/local/sbin/hytale-autoupdate.sh >> /var/log/hytale-autoupdate.log 2>&1
```

Lo script usa `flock`, `timeout`, versione online via downloader, unzip overwrite, `chmod +x start.sh`, log separato e riavvio servizio.

Se dopo update appare `status=203/EXEC`:

```bash
sudo chmod +x /home/hytale/hytale/start.sh
sudo systemctl restart hytale-server
```
