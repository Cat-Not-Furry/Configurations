#!/usr/bin/env bash
# Asegura nm-applet, blueman-applet y copyq tras waybar/i3bar (bandeja lista).
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib/session-env.sh
source "$SCRIPT_DIR/lib/session-env.sh"

mode="hyprland"
if [ -f "$SESSION_MODE_FILE" ]; then
  mode="$(tr -d '[:space:]' <"$SESSION_MODE_FILE")"
fi

ensure_tray_applets "$mode"
