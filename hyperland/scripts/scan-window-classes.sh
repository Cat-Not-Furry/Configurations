#!/usr/bin/env bash
# Lista ventanas activas (class, title, float).
# Uso: abre un diálogo problemático y ejecuta este script para añadir reglas en conf.d/windowrules.conf

set -euo pipefail

if ! command -v hyprctl >/dev/null 2>&1; then
  echo "hyprctl no encontrado" >&2
  exit 1
fi

if ! command -v jq >/dev/null 2>&1; then
  echo "jq no encontrado (pacman -S jq)" >&2
  exit 1
fi

echo "=== Todas las ventanas ==="
hyprctl clients -j | jq -r '.[] | "\(.class) | \(.title) | float=\(.floating)"'

echo
echo "=== Solo tiled (candidatas a regla float) ==="
hyprctl clients -j | jq -r '.[] | select(.floating == false) | "\(.class) | \(.title)"'
