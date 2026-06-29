#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib/waybar-autohide.sh
source "$SCRIPT_DIR/lib/waybar-autohide.sh"

mode="$(read_autohide_mode)"
position="$(read_waybar_position)"

if [ "$mode" = "normal" ]; then
  printf -- '-'
elif [ "$position" = "bottom" ]; then
  printf 'v'
else
  printf '^'
fi
