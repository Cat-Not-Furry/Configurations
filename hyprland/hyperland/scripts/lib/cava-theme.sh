#!/usr/bin/env bash
# Activar perfil Cava: cp wayland/config.{slug} → config; si cava corre, terminarlo (sin relanzar).

cava_notify_err() {
  local msg="$1"
  echo "cava-theme: $msg" >&2
  if command -v notify-send >/dev/null 2>&1; then
    notify-send -u critical "Cava" "$msg" 2>/dev/null || true
  fi
}

find_palettes_file() {
  local candidate
  for candidate in \
    "$HOME/.config/ignis/themes/palettes.json" \
    "${HYPRLAND_ROOT:-}/themes/palettes.json" \
    "${CONFIG_ROOT:-}/hyprland/hyperland/themes/palettes.json" \
    "${HYPRLAND_ROOT:-$HOME/hyprland}/themes/palettes.json" \
    "${CONFIG_ROOT:-$HOME/hyprland}/themes/palettes.json"; do
    if [ -f "$candidate" ]; then
      echo "$candidate"
      return 0
    fi
  done
  return 1
}

activate_cava_profile() {
  local theme_id="${1:-}"
  local palettes cava_slug src dst

  if [ -z "$theme_id" ]; then
    echo "cava-theme: theme_id vacío; omitido." >&2
    return 0
  fi

  palettes="$(find_palettes_file)" || {
    cava_notify_err "No se encontró palettes.json para Cava."
    return 1
  }

  cava_slug="$(python3 - "$theme_id" "$palettes" <<'PY'
import json
import sys
from pathlib import Path

theme_id = sys.argv[1]
p = Path(sys.argv[2])
data = json.loads(p.read_text())
theme = data.get("themes", {}).get(theme_id, {})
print(theme.get("cava", theme_id.replace("_", "-")))
PY
)"

  src="${HOME}/.config/cava/wayland/config.${cava_slug}"
  dst="${HOME}/.config/cava/config"

  if [ ! -f "$src" ]; then
    cava_notify_err "No existe ${src} para el tema ${theme_id}."
    return 1
  fi

  mkdir -p "$(dirname "$dst")"
  cp "$src" "$dst"
  echo "Cava: config.${cava_slug} → config"

  if pgrep -x cava >/dev/null 2>&1; then
    killall cava 2>/dev/null || true
    echo "Cava: instancia terminada (relanzar manualmente si lo necesitas)"
  fi

  return 0
}
