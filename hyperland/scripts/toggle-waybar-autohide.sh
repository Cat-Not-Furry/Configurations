#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib/waybar-autohide.sh
source "$SCRIPT_DIR/lib/waybar-autohide.sh"

LOG="${HOME}/.cache/hypr/waybar-autohide-toggle.log"
mkdir -p "$(dirname "$LOG")"

mode="$(read_autohide_mode)"
if [ "$mode" = "normal" ]; then
  target="autohide"
else
  target="normal"
fi

# Desacoplado: si matamos waybar dentro del on-click, el script muere antes de terminar.
nohup "$SCRIPT_DIR/waybar-autohide-apply.sh" "$target" >>"$LOG" 2>&1 &
