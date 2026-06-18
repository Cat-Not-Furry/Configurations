#!/usr/bin/env bash
set -euo pipefail

RAW="${1:?Uso: hyprsunset-set-temp.sh TEMPERATURA}"
STATE_DIR="$HOME/.cache/ignis"
STATE_FILE="$STATE_DIR/hyprsunset.state"

TEMP=$(python3 -c "
temp = max(1000, min(20000, int('$RAW')))
print(round(temp / 1000) * 1000)
")

hyprctl hyprsunset temperature "$TEMP"
printf '{"active": true, "temperature": %s}\n' "$TEMP" > "$STATE_FILE"
