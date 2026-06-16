#!/usr/bin/env bash
set -euo pipefail

if ! command -v grim >/dev/null 2>&1; then
    echo "grim no está instalado" >&2
    exit 1
fi

if ! command -v wl-copy >/dev/null 2>&1; then
    echo "wl-copy no está instalado" >&2
    exit 1
fi

CX="$(hyprctl cursorpos -j | jq -r '.x')"
CY="$(hyprctl cursorpos -j | jq -r '.y')"

if [[ -z "$CX" || -z "$CY" || "$CX" == "null" || "$CY" == "null" ]]; then
    echo "No se pudo obtener la posición del cursor" >&2
    exit 1
fi

GEO="$(hyprctl monitors -j | jq -r --argjson cx "$CX" --argjson cy "$CY" '
  .[] | select(
    ($cx >= .x) and ($cx < (.x + (.width / .scale | floor))) and
    ($cy >= .y) and ($cy < (.y + (.height / .scale | floor)))
  ) | "\(.x),\(.y) \((.width / .scale) | floor)x\((.height / .scale) | floor)"
' | head -n1)"

if [[ -z "$GEO" ]]; then
    echo "No se encontró monitor bajo el cursor ($CX, $CY)" >&2
    exit 1
fi

grim -g "$GEO" - | wl-copy --type image/png
