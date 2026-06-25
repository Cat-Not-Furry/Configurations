#!/usr/bin/env bash
# Abre/cierra hyprexpo + submap de teclado.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CACHE="${XDG_CACHE_HOME:-$HOME/.cache}/hyprexpo/nav-active"
ACTION="${1:-toggle}"

case "$ACTION" in
  toggle)
    if [[ -f "$CACHE" ]]; then
      "$SCRIPT_DIR/hyprexpo-exit.sh"
    else
      "$SCRIPT_DIR/hyprexpo-preopen.sh"
      hyprctl dispatch hyprexpo:expo on
      touch "$CACHE"
      hyprctl dispatch submap hyprexpo-nav
    fi
    ;;
  cancel)
    "$SCRIPT_DIR/hyprexpo-exit.sh"
    ;;
  *)
    echo "Uso: hyprexpo-nav.sh {toggle|cancel}" >&2
    exit 1
    ;;
esac
