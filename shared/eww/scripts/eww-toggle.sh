#!/usr/bin/env bash
set -euo pipefail

window="${1:-}"

if [ -z "$window" ]; then
  exit 1
fi

if ! command -v eww >/dev/null 2>&1; then
  exit 1
fi

if ! pgrep -x eww >/dev/null 2>&1; then
  notify-send -t 3000 "Eww" "Inicia el daemon con Super+Shift+P" 2>/dev/null || true
  exit 1
fi

if eww active-windows 2>/dev/null | grep -qw "$window"; then
  eww close "$window"
else
  eww open "$window"
fi
