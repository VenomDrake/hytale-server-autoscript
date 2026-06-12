# Prima autenticazione OAuth

> This documentation is currently written in Italian. English docs are planned.


Il server Hytale richiede autenticazione OAuth manuale al primo avvio.

```bash
sudo systemctl stop hytale-server
sudo -u hytale -H bash -lc 'cd /home/hytale/hytale && ./start.sh'
```

Nella console Hytale esegui:

```text
/auth login device
/auth persistence Encrypted
/auth status
```

Stato corretto:

```text
Session Token: Present
Identity Token: Present
Credentials saved using: Encrypted
```

Poi ferma dalla console:

```text
/stop
```

E riavvia come servizio:

```bash
sudo systemctl start hytale-server
```

Non includere mai `auth.enc` nella repository.
