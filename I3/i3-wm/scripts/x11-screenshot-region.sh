#!/usr/bin/env bash
# Captura región (X11): maim + slop → portapapeles.
set -euo pipefail

_notify_err() {
  echo "x11-screenshot: $*" >&2
  command -v notify-send >/dev/null 2>&1 &&
    notify-send -u critical "Captura de pantalla" "$*" 2>/dev/null || true
}

_notify_ok() {
  command -v notify-send >/dev/null 2>&1 &&
    notify-send -t 2500 -i camera-photo-symbolic "Captura de pantalla" "$*" 2>/dev/null || true
}

for cmd in maim xclip; do
  if ! command -v "$cmd" >/dev/null 2>&1; then
    _notify_err "$cmd no está instalado."
    exit 1
  fi
done

if ! command -v slop >/dev/null 2>&1; then
  _notify_err "slop no está instalado (necesario para seleccionar región)."
  exit 1
fi

if ! maim -s 2>/dev/null | xclip -selection clipboard -t image/png; then
  _notify_err "Captura cancelada (Esc)."
  exit 1
fi

_notify_ok "Región copiada al portapapeles."
