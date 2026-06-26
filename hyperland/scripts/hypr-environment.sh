#!/usr/bin/env bash
# Vuelve al perfil Hyprland/Wayland (bash + env + cava wayland).
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib/project-paths.sh
source "$SCRIPT_DIR/lib/project-paths.sh"
resolve_project_paths "$SCRIPT_DIR"
# shellcheck source=lib/session-env.sh
source "$SCRIPT_DIR/lib/session-env.sh"
# shellcheck source=lib/cava-theme.sh
source "$SCRIPT_DIR/lib/cava-theme.sh"

STATE_FILE="${SESSION_MODE_FILE}"
BASH_HYPR="${CONFIG_ROOT}/bash/bashrc.hypr"

usage() {
  cat <<EOF
Uso: $(basename "$0") [--help]

Restaura perfil Hyprland/Wayland:
  - session-mode → hyprland
  - ~/.bashrc ← bash/bashrc.hypr (powerline)
  - env.active.sh Wayland
  - cava wayland según tema activo

Luego: source ~/.bashrc
EOF
}

for arg in "$@"; do
  case "$arg" in
    -h | --help) usage; exit 0 ;;
    *) echo "Opción desconocida: $arg" >&2; usage >&2; exit 1 ;;
  esac
done

write_session_mode hyprland

stop_x11_session_processes

if [ ! -f "$BASH_HYPR" ]; then
  echo "Error: no se encontró $BASH_HYPR" >&2
  exit 1
fi

cp "$BASH_HYPR" "${HOME}/.bashrc"
echo "Bash: bashrc.hypr → ~/.bashrc"

write_hypr_env
propagate_env_from_file

THEME_ID=""
if [ -f "${HOME}/.cache/ignis/active-theme.json" ]; then
  THEME_ID="$(python3 -c "import json; print(json.load(open('${HOME}/.cache/ignis/active-theme.json')).get('active',''))" 2>/dev/null || true)"
fi
if [ -z "$THEME_ID" ] && [ -f "${HYPRLAND_ROOT}/themes/palettes.json" ]; then
  THEME_ID="$(python3 -c "import json; d=json.load(open('${HYPRLAND_ROOT}/themes/palettes.json')); print((d.get('order') or ['blue'])[0])" 2>/dev/null || echo blue)"
fi
activate_cava_profile "${THEME_ID:-blue}" || true

# shellcheck disable=SC1091
[ -f "${HOME}/.config/bash/env.active.sh" ] && source "${HOME}/.config/bash/env.active.sh"

echo "Perfil Hyprland/Wayland restaurado."
