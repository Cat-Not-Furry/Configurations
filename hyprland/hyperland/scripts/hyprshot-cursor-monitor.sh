#!/usr/bin/env bash
set -euo pipefail

notify_err() {
  local msg="$1"
  echo "hyprshot-cursor-monitor: $msg" >&2
  if command -v notify-send >/dev/null 2>&1; then
    notify-send -u critical "Captura de pantalla" "$msg" 2>/dev/null || true
  fi
}

notify_ok() {
  local msg="$1"
  if command -v notify-send >/dev/null 2>&1; then
    notify-send -t 2500 -i camera-photo-symbolic "Captura de pantalla" "$msg" 2>/dev/null || true
  fi
}

if ! command -v grim >/dev/null 2>&1; then
  notify_err "grim no está instalado."
  exit 1
fi

if ! command -v wl-copy >/dev/null 2>&1; then
  notify_err "wl-copy no está instalado."
  exit 1
fi

CX="$(hyprctl cursorpos -j | jq -r '.x')"
CY="$(hyprctl cursorpos -j | jq -r '.y')"

if [[ -z "$CX" || -z "$CY" || "$CX" == "null" || "$CY" == "null" ]]; then
  notify_err "No se pudo obtener la posición del cursor."
  exit 1
fi

GEO="$(hyprctl monitors -j | jq -r --argjson cx "$CX" --argjson cy "$CY" '
  .[] | select(
    ($cx >= .x) and ($cx < (.x + (.width / .scale | floor))) and
    ($cy >= .y) and ($cy < (.y + (.height / .scale | floor)))
  ) | "\(.x),\(.y) \((.width / .scale) | floor)x\((.height / .scale) | floor)"
' | head -n1)"

if [[ -z "$GEO" ]]; then
  notify_err "No se encontró monitor bajo el cursor ($CX, $CY)."
  exit 1
fi

if grim -g "$GEO" - | wl-copy --type image/png; then
  notify_ok "Monitor bajo el cursor copiado al portapapeles."
else
  notify_err "No se pudo capturar ni copiar la imagen."
  exit 1
fi
