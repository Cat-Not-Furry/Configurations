#!/usr/bin/env bash
# Activar perfil Wofi: cp wayland/colors.{slug} y style.{slug}.css → ~/.config/wofi/

wofi_notify_err() {
  local msg="$1"
  echo "wofi-theme: $msg" >&2
  if command -v notify-send >/dev/null 2>&1; then
    notify-send -u critical "Wofi" "$msg" 2>/dev/null || true
  fi
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

resolve_wofi_slug() {
  local theme_id="$1"
  local palettes="$2"
  python3 - "$theme_id" "$palettes" <<'PY'
import json
import sys
from pathlib import Path

theme_id = sys.argv[1]
p = Path(sys.argv[2])
data = json.loads(p.read_text())
theme = data.get("themes", {}).get(theme_id, {})
print(theme.get("wofi", theme.get("cava", theme_id.replace("_", "-"))))
PY
}

activate_wofi_profile() {
  local theme_id="${1:-}"
  local palettes wofi_slug colors_src style_src

  if [ -z "$theme_id" ]; then
    echo "wofi-theme: theme_id vacío; omitido." >&2
    return 0
  fi

  palettes="$(find_palettes_file)" || {
    wofi_notify_err "No se encontró palettes.json para Wofi."
    return 1
  }

  wofi_slug="$(resolve_wofi_slug "$theme_id" "$palettes")"
  colors_src="${HOME}/.config/wofi/wayland/colors.${wofi_slug}"
  style_src="${HOME}/.config/wofi/wayland/style.${wofi_slug}.css"

  if [ ! -f "$colors_src" ]; then
    wofi_notify_err "No existe ${colors_src} para el tema ${theme_id}."
    return 1
  fi
  if [ ! -f "$style_src" ]; then
    wofi_notify_err "No existe ${style_src} para el tema ${theme_id}."
    return 1
  fi

  mkdir -p "${HOME}/.config/wofi"
  cp "$colors_src" "${HOME}/.config/wofi/colors"
  cp "$style_src" "${HOME}/.config/wofi/style.css"
  echo "Wofi: colors.${wofi_slug} + style.${wofi_slug}.css → activos"
  return 0
}
