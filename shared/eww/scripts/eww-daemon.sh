#!/usr/bin/env bash
set -euo pipefail

EWW_CONFIG="${EWW_CONFIG:-$HOME/.config/eww}"

if ! command -v eww >/dev/null 2>&1; then
  notify-send -t 3000 "Eww" "eww no está instalado (pacman -S eww)" 2>/dev/null || true
  exit 1
fi

if pgrep -x eww >/dev/null 2>&1; then
  notify-send -t 2000 "Eww" "El daemon ya está activo" 2>/dev/null || true
  exit 0
fi

cd "$EWW_CONFIG"
eww daemon
sleep 0.3
notify-send -t 2000 "Eww" "Daemon iniciado" 2>/dev/null || true
