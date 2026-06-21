#!/usr/bin/env bash
# Fragmentos de entorno Hyprland (Wayland) vs X11/i3 — escrito por *-environment.sh

write_hypr_env() {
  local dest="${HOME}/.config/bash/env.active.sh"
  mkdir -p "$(dirname "$dest")"
  cat >"$dest" <<'EOF'
# Generado por hypr-environment.sh — no editar a mano
export XDG_SESSION_TYPE=wayland
export GDK_BACKEND=wayland
export QT_QPA_PLATFORM=wayland
export QT_QPA_PLATFORMTHEME=qt5ct
export XDG_CURRENT_DESKTOP=Hyprland
EOF
  echo "Entorno: perfil Hyprland → $dest"
}

write_x11_env() {
  local dest="${HOME}/.config/bash/env.active.sh"
  mkdir -p "$(dirname "$dest")"
  cat >"$dest" <<'EOF'
# Generado por x11-environment.sh — no editar a mano
export XDG_SESSION_TYPE=x11
export GDK_BACKEND=x11
export QT_QPA_PLATFORM=xcb
export QT_QPA_PLATFORMTHEME=qt5ct
export XDG_CURRENT_DESKTOP=i3
unset WAYLAND_DISPLAY 2>/dev/null || true
EOF
  echo "Entorno: perfil X11/i3 → $dest"
}

activate_cava_x11_profile() {
  local theme_id="${1:-}"
  local palettes cava_slug src dst

  if [ -z "$theme_id" ] && [ -f "${HOME}/.cache/ignis/active-theme.json" ]; then
    theme_id="$(python3 -c "import json; print(json.load(open('${HOME}/.cache/ignis/active-theme.json')).get('active',''))" 2>/dev/null || true)"
  fi
  theme_id="${theme_id:-blue}"

  # shellcheck source=lib/cava-theme.sh
  source "$(dirname "${BASH_SOURCE[0]}")/cava-theme.sh"

  palettes="$(find_palettes_file)" || {
    echo "cava-x11: palettes.json no encontrado; usando config.txt" >&2
    src="${CONFIG_ROOT:-$HOME/hyprland}/cava/x11/config.txt"
    dst="${HOME}/.config/cava/config"
    if [ -f "$src" ]; then
      mkdir -p "$(dirname "$dst")"
      cp "$src" "$dst"
      echo "Cava X11: config.txt → config"
    fi
    return 0
  }

  cava_slug="$(python3 - "$theme_id" "$palettes" <<'PY'
import json, sys
from pathlib import Path
theme_id = sys.argv[1]
data = json.loads(Path(sys.argv[2]).read_text())
theme = data.get("themes", {}).get(theme_id, {})
print(theme.get("cava", theme_id.replace("_", "-")))
PY
)"

  local root="${CONFIG_ROOT:-$HOME/hyprland}"
  for src in \
    "${HOME}/.config/cava/x11/config.${cava_slug}" \
    "$root/cava/x11/config.${cava_slug}" \
    "${HOME}/.config/cava/x11/config.txt" \
    "$root/cava/x11/config.txt"; do
    if [ -f "$src" ]; then
      dst="${HOME}/.config/cava/config"
      mkdir -p "$(dirname "$dst")"
      cp "$src" "$dst"
      echo "Cava X11: $(basename "$src") → config"
      if pgrep -x cava >/dev/null 2>&1; then
        killall cava 2>/dev/null || true
        echo "Cava: instancia terminada (relanzar manualmente en X11)"
      fi
      return 0
    fi
  done
  echo "cava-x11: no hay config X11; omitido." >&2
  return 1
}
