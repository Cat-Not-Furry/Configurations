#!/usr/bin/env bash
# Captura región Wayland: slurp + grim → portapapeles (cancel Esc → notificación).
set -euo pipefail

_notify_err() {
  echo "hyprshot-region: $*" >&2
  command -v notify-send >/dev/null 2>&1 &&
    notify-send -u critical "Captura de pantalla" "$*" 2>/dev/null || true
}

_notify_ok() {
  command -v notify-send >/dev/null 2>&1 &&
    notify-send -t 2500 -i camera-photo-symbolic "Captura de pantalla" "$*" 2>/dev/null || true
}

for cmd in slurp grim wl-copy; do
  if ! command -v "$cmd" >/dev/null 2>&1; then
    _notify_err "$cmd no está instalado."
    exit 1
  fi
done

geometry="$(slurp -d 2>/dev/null)" || true

if [ -z "${geometry// /}" ]; then
  _notify_err "Captura cancelada (Esc)."
  exit 1
fi

if grim -g "${geometry}" - | wl-copy --type image/png; then
  _notify_ok "Región copiada al portapapeles."
else
  _notify_err "No se pudo capturar la región."
  exit 1
fi
