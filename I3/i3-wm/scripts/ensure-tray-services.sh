#!/usr/bin/env bash
# Asegura nm-applet, blueman-applet y copyq tras i3bar (bandeja X11 lista).
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

load_session_libs() {
  local session
  for session in \
    "${HOME}/.config/hypr/scripts/lib/session-env.sh" \
    "$SCRIPT_DIR/../../../hyprland/hyperland/scripts/lib/session-env.sh" \
    "$SCRIPT_DIR/../../hyperland/scripts/lib/session-env.sh"; do
    if [ -f "$session" ]; then
      # shellcheck source=/dev/null
      source "$session"
      return 0
    fi
  done
  return 1
}

if ! load_session_libs; then
  echo "ensure-tray-services: no se encontró session-env.sh" >&2
  exit 1
fi

ensure_tray_applets x11
