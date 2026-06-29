#!/usr/bin/env bash
# Toggle CopyQ y fuerza flotante + tamaño (i3 a veces no aplica for_window al mapear).
set -euo pipefail

copyq toggle
sleep 0.15

if command -v i3-msg >/dev/null 2>&1 && [[ -n "${DISPLAY:-}" ]]; then
  i3-msg '[class="copyq"] floating enable, resize set 800 600, move position center' 2>/dev/null || true
  i3-msg '[class="Copyq"] floating enable, resize set 800 600, move position center' 2>/dev/null || true
fi
