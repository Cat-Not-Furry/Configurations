#!/usr/bin/env bash
set -euo pipefail

STATE_DIR="$HOME/.cache/ignis"
STATE_FILE="$STATE_DIR/hyprsunset.state"

hyprctl hyprsunset identity
printf '{"active": false, "temperature": 6500}\n' > "$STATE_FILE"
