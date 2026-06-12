# Changelog

All notable changes to this project will be documented in this file.

## [1.0.0] - 2026-06-12

### Initial release

- Added the first public release of Hytale Server Manager.
- Added an Ubuntu 24.04 LTS installer for Temurin 25 Adoptium, a dedicated `hytale` user, the official Hytale Downloader CLI, firewall setup, server configuration, and final installation checks.
- Added a `systemd` service template for `hytale-server` with automatic startup and restart behavior.
- Added the main `./hytale` wrapper command for everyday server operations such as start, stop, restart, status, logs, console, update, backup, restore, monitor, healthcheck, version, ports, and auth help.
- Added manual and automatic update tooling, including `scripts/hytale-autoupdate.sh`, cron integration, version checks, locking, logging, and safe service restart behavior on failures.
- Added manual backup and restore scripts for server configuration, universe data, bans, whitelist, permissions, and server backup folders while excluding credentials.
- Added monitoring and healthcheck scripts for service state, UDP port checks, Java process checks, memory, disk, and version visibility.
- Added multilingual README support with English as the default README and an Italian translation.
- Added Proxmox LXC documentation and operational notes.
- Added security and contributing documentation for community usage and safe handling of credentials/runtime files.
- Added a GitHub Actions ShellCheck workflow that runs shell syntax validation and ShellCheck on pull requests and pushes.
