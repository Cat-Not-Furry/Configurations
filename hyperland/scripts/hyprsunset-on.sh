#!/usr/bin/env bash
set -euo pipefail

TEMP="${1:-1000}"
STATE_DIR="$HOME/.cache/ignis"
STATE_FILE="$STATE_DIR/hyprsunset.state"

mkdir -p "$STATE_DIR"
hyprctl hyprsunset temperature "$TEMP"
printf '{"active": true, "temperature": %s}\n' "$TEMP" > "$STATE_FILE"
