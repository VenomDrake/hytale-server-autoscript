# Contributing

Thanks for helping improve Hytale Server Manager.

## Opening issues

Open an issue when you find a bug, have a documentation improvement, or want to propose a new feature. Please include:

- Ubuntu/LXC environment details.
- The command you ran.
- Relevant output or logs with secrets removed.
- Steps to reproduce the problem.

## Pull requests

Before submitting a pull request:

1. Keep changes focused and easy to review.
2. Update README or docs when behavior changes.
3. Do not include proprietary Hytale server files or generated runtime data.
4. Run the local validation commands below.

## Local script testing

Run syntax checks:

```bash
git diff --check
bash -n install.sh update.sh backup.sh restore.sh monitor.sh hytale scripts/*.sh
```

If ShellCheck is installed, run:

```bash
shellcheck install.sh update.sh backup.sh restore.sh monitor.sh hytale scripts/*.sh
```

## Do not commit sensitive or generated files

Never commit:

- Hytale server files or `Server/` runtime data.
- Server ZIP files or any `*.zip`.
- `Assets.zip`.
- `auth.enc` or any `*.enc` credential file.
- `.hytale-downloader-credentials.json` or related credential files.
- Backups, `*.tar.gz`, logs, temporary files, or `.env` files.
