#!/usr/bin/env bash
set -euo pipefail

if ! command -v eww >/dev/null 2>&1; then
  exit 0
fi

eww kill 2>/dev/null || true
notify-send -t 2000 "Eww" "Daemon detenido" 2>/dev/null || true
