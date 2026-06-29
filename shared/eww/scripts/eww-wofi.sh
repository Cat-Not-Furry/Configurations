#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WOFI_COMMON="$HOME/.config/hypr/scripts/lib/wofi-common.sh"

if ! pgrep -x eww >/dev/null 2>&1; then
  notify-send -t 3000 "Eww" "Inicia el daemon con Super+Shift+P" 2>/dev/null || true
  exit 1
fi

if [ -f "$WOFI_COMMON" ]; then
  # shellcheck source=/dev/null
  source "$WOFI_COMMON"
else
  wofi_dmenu() { wofi --dmenu --insensitive "$@"; }
fi

opcion=$(printf '%s\n' \
  "Sistema" \
  "Calendario" \
  "Actualizaciones" \
  | wofi_dmenu --prompt "Eww:")

case "$opcion" in
  Sistema)
    "$SCRIPT_DIR/eww-toggle.sh" system_window
    ;;
  Calendario)
    "$SCRIPT_DIR/eww-toggle.sh" calendar_window
    ;;
  Actualizaciones)
    "$SCRIPT_DIR/eww-toggle.sh" updates_window
    ;;
  *)
    ;;
esac
