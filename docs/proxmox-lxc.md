# Proxmox LXC

Configurazione consigliata:

- Ubuntu 24.04 LTS.
- 8 core e 32 GB RAM per il profilo JVM incluso.
- Disco 80 GB minimo, 120 GB o più consigliati.
- Apri UDP 5520 su firewall container, nodo Proxmox, router e provider.
- Se `timedatectl` non funziona nel container, configura timezone dal nodo o verifica `/etc/timezone`.
- Verifica risorse con `./hytale monitor` e stato con `./hytale healthcheck`.

Nota: il profilo `jvm.options` usa heap fisso 12 GB; riducilo se il container ha meno RAM.
