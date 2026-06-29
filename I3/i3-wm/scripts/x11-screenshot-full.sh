#!/usr/bin/env bash
# Captura pantalla completa (X11): maim → portapapeles.
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

if maim | xclip -selection clipboard -t image/png; then
  _notify_ok "Pantalla completa copiada al portapapeles."
else
  _notify_err "No se pudo capturar la pantalla."
  exit 1
fi
