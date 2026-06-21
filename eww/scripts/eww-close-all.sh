#!/usr/bin/env bash
set -euo pipefail

if ! command -v eww >/dev/null 2>&1; then
  exit 0
fi

if ! pgrep -x eww >/dev/null 2>&1; then
  notify-send -t 2000 "Eww" "El daemon no está activo" 2>/dev/null || true
  exit 0
fi

eww close-all 2>/dev/null || true
notify-send -t 2000 "Eww" "Ventanas cerradas" 2>/dev/null || true
