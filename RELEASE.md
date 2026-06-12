# Release Checklist

Use this checklist for manual public releases.

## v1.0.0 release checklist

1. Run shell syntax validation:

   ```bash
   bash -n install.sh update.sh backup.sh restore.sh monitor.sh hytale scripts/*.sh
   ```

2. Run ShellCheck locally, or wait for the GitHub Actions CI workflow if ShellCheck is not available locally:

   ```bash
   shellcheck install.sh update.sh backup.sh restore.sh monitor.sh hytale scripts/*.sh
   ```

3. Verify README links:

   ```bash
   python3 - <<'PY'
   from pathlib import Path
   import re
   import sys

   ok = True
   for fname in ["README.md", "README.it.md"]:
       text = Path(fname).read_text()
       for url in re.findall(r"(?<!!)(?:\[[^\]]+\])\(([^)]+)\)", text):
           if "://" in url or url.startswith("#"):
               continue
           path = url.split("#", 1)[0]
           if path and not Path(path).exists():
               print(f"BROKEN {fname}: {url}")
               ok = False
   sys.exit(0 if ok else 1)
   PY
   ```

4. Verify no runtime/server files are committed:

   ```bash
   find . -path ./.git -prune -o \
     \( -name '*.zip' -o -name 'Assets.zip' -o -name 'auth.enc' -o -name '*.enc' \
     -o -name '.hytale-downloader-credentials.json*' -o -path './Server/*' \) -print
   ```

   The command should print no files.

5. Verify `LICENSE` exists and contains the MIT license.

6. Verify install instructions on a clean Ubuntu 24.04 LTS host or Proxmox LXC container:

   ```bash
   REPO_URL="https://github.com/YOUR-USERNAME/hytale-server-manager.git"
   git clone "$REPO_URL"
   cd hytale-server-manager
   chmod +x install.sh
   sudo ./install.sh
   ```

7. Create the release tag:

   ```bash
   git tag -a v1.0.0 -m "Hytale Server Manager v1.0.0"
   ```

8. Push the tag:

   ```bash
   git push origin v1.0.0
   ```

9. Create the GitHub release from tag `v1.0.0` and include highlights from `CHANGELOG.md`.
