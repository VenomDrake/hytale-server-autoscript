# OP e permessi

> This documentation is currently written in Italian. English docs are planned.


Console manuale:

```bash
sudo systemctl stop hytale-server
sudo -u hytale -H bash -lc 'cd /home/hytale/hytale && ./start.sh'
```

Dentro console:

```text
/op add VenomDrake
```

Oppure modifica `/home/hytale/hytale/Server/permissions.json`.

Esempio:

```json
{
  "users": {
    "ab61be40-440f-417c-ab1a-ffe15b2a0c0d": {
      "groups": ["OP"]
    }
  },
  "groups": {
    "Default": [],
    "OP": ["*"]
  }
}
```
