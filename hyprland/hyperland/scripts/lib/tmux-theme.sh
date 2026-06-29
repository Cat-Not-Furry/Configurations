#!/usr/bin/env bash
# Activar perfil tmux: cp colors/{slug}.conf → colors.active.conf; recargar si hay server.

tmux_notify_err() {
  local msg="$1"
  echo "tmux-theme: $msg" >&2
}

find_palettes_file() {
  local candidate
  for candidate in \
    "$HOME/.config/ignis/themes/palettes.json" \
    "${HYPRLAND_ROOT:-$HOME/hyprland}/themes/palettes.json" \
    "${CONFIG_ROOT:-$HOME/hyprland}/themes/palettes.json"; do
    if [ -f "$candidate" ]; then
      echo "$candidate"
      return 0
    fi
  done
  return 1
}

activate_tmux_profile() {
  local theme_id="${1:-}"
  local palettes tmux_slug colors_src active_dst tmux_conf

  if [ -z "$theme_id" ]; then
    echo "tmux-theme: theme_id vacío; omitido." >&2
    return 0
  fi

  palettes="$(find_palettes_file)" || {
    tmux_notify_err "No se encontró palettes.json para tmux."
    return 1
  }

  tmux_slug="$(python3 - "$theme_id" "$palettes" <<'PY'
import json
import sys
from pathlib import Path

theme_id = sys.argv[1]
p = Path(sys.argv[2])
data = json.loads(p.read_text())
theme = data.get("themes", {}).get(theme_id, {})
print(theme.get("tmux", theme.get("cava", theme.get("wofi", theme_id.replace("_", "-")))))
PY
)"

  if [ -e "${HOME}/.config/tmux" ] && [ ! -d "${HOME}/.config/tmux" ]; then
    tmux_notify_err "${HOME}/.config/tmux existe pero no es un directorio."
    return 1
  fi

  colors_src="${HOME}/.config/tmux/colors/${tmux_slug}.conf"
  active_dst="${HOME}/.config/tmux/colors.active.conf"
  tmux_conf="${HOME}/.config/tmux/tmux.conf"

  if [ ! -f "$colors_src" ]; then
    tmux_notify_err "No existe ${colors_src} para el tema ${theme_id}."
    return 1
  fi

  mkdir -p "${HOME}/.config/tmux"
  cp "$colors_src" "$active_dst"
  echo "Tmux: colors/${tmux_slug}.conf → colors.active.conf"

  if [ -f "$tmux_conf" ] && tmux info &>/dev/null; then
    tmux source-file "$tmux_conf" 2>/dev/null && echo "Tmux: config recargada en sesión activa" || true
  fi

  return 0
}
