#!/usr/bin/env bash
# Alterna barra i3: bumblebee-status (fijo) ↔ polybar (prueba + temas).
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
I3_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
BAR_DIR="$I3_ROOT/conf.d/bar-mode"
BBAR="$I3_ROOT/conf.d/05-bbar.conf"
MODE_FILE="${XDG_CACHE_HOME:-$HOME/.cache}/i3/status-bar-mode"
POLYBAR_LAUNCH="${HOME}/.config/polybar/launch.sh"

usage() {
  cat <<EOF
Uso: $(basename "$0") [bumblebee|polybar|toggle|status]

  bumblebee  05-bbar.conf original + bumblebee-status
  polybar    i3bar oculto + polybar
EOF
}

notify() {
  command -v notify-send >/dev/null 2>&1 &&
    notify-send -t 3000 "Barra i3" "$1" 2>/dev/null || true
}

resolve_i3_root() {
  if [[ -d "${HOME}/.config/i3/conf.d/bar-mode" ]]; then
    BAR_DIR="${HOME}/.config/i3/conf.d/bar-mode"
    BBAR="${HOME}/.config/i3/conf.d/05-bbar.conf"
  fi
}

current_mode() {
  if [[ -f "$MODE_FILE" ]]; then
    tr -d '[:space:]' <"$MODE_FILE"
    return 0
  fi
  if pgrep -x polybar >/dev/null 2>&1; then
    echo polybar
    return 0
  fi
  echo bumblebee
}

stop_polybar() {
  killall -q polybar 2>/dev/null || true
  local i=0
  while pgrep -u "$UID" -x polybar >/dev/null 2>&1 && [[ "$i" -lt 20 ]]; do
    sleep 0.2
    i=$((i + 1))
  done
  pgrep -u "$UID" -x polybar >/dev/null 2>&1 && killall -9 -q polybar 2>/dev/null || true
}

apply_mode() {
  local mode="$1"
  local src="$BAR_DIR/${mode}.conf"

  if [[ ! -f "$src" ]]; then
    echo "toggle-status-bar: falta $src" >&2
    exit 1
  fi

  mkdir -p "$(dirname "$MODE_FILE")"
  cp "$src" "$BBAR"
  printf '%s\n' "$mode" >"$MODE_FILE"

  case "$mode" in
    polybar)
      if [[ ! -x "$POLYBAR_LAUNCH" ]]; then
        echo "toggle-status-bar: no existe $POLYBAR_LAUNCH" >&2
        exit 1
      fi
      ;;
    bumblebee)
      stop_polybar
      ;;
  esac

  if command -v i3-msg >/dev/null 2>&1 && [[ -n "${DISPLAY:-}" ]]; then
    i3-msg reload >/dev/null 2>&1 || i3-msg restart
  fi

  if [[ "$mode" = polybar ]] && [[ -x "$POLYBAR_LAUNCH" ]]; then
    sleep 0.5
    pgrep -x polybar >/dev/null 2>&1 || "$POLYBAR_LAUNCH" &
  fi

  echo "Barra i3: $mode"
  notify "Modo activo: $mode"
}

resolve_i3_root

ACTION="${1:-toggle}"
case "$ACTION" in
  status) current_mode ;;
  toggle)
    if [[ "$(current_mode)" = polybar ]]; then
      apply_mode bumblebee
    else
      apply_mode polybar
    fi
    ;;
  bumblebee | polybar) apply_mode "$ACTION" ;;
  -h | --help) usage ;;
  *)
    echo "Modo desconocido: $ACTION" >&2
    usage >&2
    exit 1
    ;;
esac
