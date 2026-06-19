#!/usr/bin/env bash
set -euo pipefail

CAVA_DIR="${CAVA_DIR:-${XDG_CONFIG_HOME:-$HOME/.config}/cava}"
CONFIG="$CAVA_DIR/config"
CAVA_ARGS=()

while [ $# -gt 0 ]; do
  case "$1" in
    --)
      shift
      CAVA_ARGS+=("$@")
      break
      ;;
    *)
      CAVA_ARGS+=("$1")
      shift
      ;;
  esac
done

mkdir -p "$CAVA_DIR"

if ! command -v cava >/dev/null 2>&1; then
  echo "cava-launch: no se encontró el ejecutable cava." >&2
  exit 1
fi

if [ ! -f "$CONFIG" ]; then
  echo "cava-launch: no hay config activo en $CONFIG" >&2
  echo "  Ejecuta apply-theme.sh o copia un perfil desde ~/.config/cava/wayland/" >&2
  exit 1
fi

exec cava -p "$CONFIG" "${CAVA_ARGS[@]}"
