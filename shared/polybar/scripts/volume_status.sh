#!/usr/bin/env bash
# Volumen sink PipeWire para polybar (hasta 200% vía wpctl --limit 2.0).
set -euo pipefail

SINK="${POLYBAR_VOLUME_SINK:-@DEFAULT_AUDIO_SINK@}"
LIMIT="${POLYBAR_VOLUME_LIMIT:-$(cnf-media --sink-limit 2>/dev/null || echo 2.0)}"
STEP="${POLYBAR_VOLUME_STEP:-0.05}"

read_volume() {
  local raw pct muted icon
  raw="$(wpctl get-volume "$SINK" 2>/dev/null)" || { echo "N/A"; return; }
  if echo "$raw" | grep -q 'MUTED'; then
    muted=1
    icon=""
  else
    muted=0
    icon=""
  fi
  pct="$(echo "$raw" | grep -oE '[0-9]+\.[0-9]+' | head -1)"
  pct="${pct:-0}"
  pct="$(awk -v v="$pct" 'BEGIN { printf "%d", v * 100 }')"
  if [[ "$muted" -eq 1 ]]; then
    printf '%s Mute' "$icon"
  else
    printf '%s %s%%' "$icon" "$pct"
  fi
}

case "${1:-}" in
  --up)
    wpctl set-volume --limit "$LIMIT" "$SINK" "${STEP}+" 2>/dev/null || true
    ;;
  --down)
    wpctl set-volume --limit "$LIMIT" "$SINK" "${STEP}-" 2>/dev/null || true
    ;;
  --toggle-mute)
    wpctl set-mute "$SINK" toggle 2>/dev/null || true
    ;;
  *)
    read_volume
    ;;
esac
