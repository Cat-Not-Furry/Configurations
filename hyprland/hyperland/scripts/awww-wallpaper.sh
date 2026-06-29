#!/usr/bin/env bash
# Establece fondo estático vía awww-daemon (una sola transición, todos los outputs).
set -euo pipefail

IMAGE="${1:-}"
TRANSITION="${2:-fade}"

if [ -z "$IMAGE" ] || [ ! -f "$IMAGE" ]; then
  echo "Uso: $(basename "$0") /ruta/imagen [transition-type]" >&2
  exit 1
fi

if ! command -v awww >/dev/null 2>&1; then
  echo "awww no está instalado" >&2
  exit 1
fi

killall mpvpaper 2>/dev/null || true

ensure_awww_daemon() {
  if pgrep -x awww-daemon >/dev/null 2>&1; then
    return 0
  fi

  local uid="${UID:-$(id -u)}"
  local stale
  for stale in /run/user/"$uid"/wayland-*-awww-daemon.sock; do
    [ -e "$stale" ] || continue
    rm -f "$stale"
  done

  awww-daemon &
  sleep 0.5

  if ! pgrep -x awww-daemon >/dev/null 2>&1; then
    echo "No se pudo iniciar awww-daemon" >&2
    return 1
  fi
}

ensure_awww_daemon
awww img "$IMAGE" --transition-type "$TRANSITION"
