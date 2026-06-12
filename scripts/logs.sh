#!/usr/bin/env bash
set -euo pipefail
journalctl -u hytale-server -f
