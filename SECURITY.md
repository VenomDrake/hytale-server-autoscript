# Security Policy

## Protect credentials

Never share or commit:

- `auth.enc`
- `.hytale-downloader-credentials.json`
- `.hytale-downloader-credentials.json*`
- Hytale server ZIP files or downloaded proprietary server files
- Backups containing world data, player data, tokens, or private configuration

If a secret is accidentally committed, remove it from the repository history and revoke or rotate the affected credentials where possible.

## Firewall recommendation

Expose only the required Hytale game port:

```bash
sudo ufw allow 5520/udp
sudo ufw enable
```

Hytale uses QUIC over UDP. Do not open TCP 5520 unless a future official Hytale release explicitly requires it. Also review Proxmox, router, and cloud-provider firewall rules.

## Reporting security issues

Please do not disclose security-sensitive issues publicly before maintainers have time to respond. Report security issues by opening a private security advisory if available on GitHub, or contact the repository owner through the preferred private contact method listed on the GitHub profile.

When reporting, include:

- A clear description of the issue.
- Steps to reproduce.
- Impact and affected files/scripts.
- Any suggested mitigation.
