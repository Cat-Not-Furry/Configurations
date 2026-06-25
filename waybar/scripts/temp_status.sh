#!/usr/bin/env bash
# Temperatura CPU: icono + °C. warning/critical al 70%/85% del límite (high/crit).
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib/threshold_class.sh
source "$SCRIPT_DIR/lib/threshold_class.sh"

temp_c=$(cat /sys/class/thermal/thermal_zone0/temp 2>/dev/null || echo 0)
temp_c=$((temp_c / 1000))

limit=100
if command -v sensors >/dev/null 2>&1; then
  high=$(sensors coretemp-isa-0000 2>/dev/null | awk '/Package id/ {
    if (match($0, /high = \+([0-9]+)/, a)) { print a[1]; exit }
    if (match($0, /crit = \+([0-9]+)/, b)) { print b[1]; exit }
  }')
  if [ -n "${high:-}" ] && [ "${high:-0}" -gt 0 ] 2>/dev/null; then
    limit=$high
  fi
fi

class=$(threshold_class "$temp_c" "$limit")
pct=0
if [ "$limit" -gt 0 ]; then
  pct=$((temp_c * 100 / limit))
fi

if [ "$class" = "critical" ]; then
  icon=""
elif [ "$class" = "warning" ]; then
  icon=""
else
  icon=""
fi

python3 - <<PY
import json
temp = ${temp_c}
limit = ${limit}
pct = ${pct}
print(json.dumps({
    "text": f"${icon} {temp}°C",
    "class": "${class}",
    "tooltip": (
        f"Temperatura: {temp}°C ({pct}% del límite {limit}°C)\\n"
        f"Naranja ≥70% · Rojo ≥85% del límite"
    ),
    "percentage": pct,
}, ensure_ascii=False))
PY
