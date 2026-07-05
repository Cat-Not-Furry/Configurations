#!/usr/bin/env bash
# Perfil X11/i3: bash legacy, variables de entorno, cava X11.
# Ejecutar al iniciar sesión i3 o antes de trabajar fuera de Hyprland.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib/project-paths.sh
source "$SCRIPT_DIR/lib/project-paths.sh"
resolve_project_paths "$SCRIPT_DIR"
# shellcheck source=lib/session-env.sh
source "$SCRIPT_DIR/lib/session-env.sh"

STATE_FILE="${SESSION_MODE_FILE}"
BASH_X11="${CONFIG_ROOT}/bash/bashrc.x11"

usage() {
  cat <<EOF
Uso: $(basename "$0") [--help]

Activa el perfil X11/i3 en ~/.config/:
  - session-mode → x11
  - ~/.bashrc ← bash/bashrc.x11
  - ~/.config/bash/env.active.sh (GDK/XDG/Qt para X11)
  - cava, tmux y copyq alineados con [i3] theme (vía apply-i3-theme / activate_x11_shared_themes)

Para aplicar en la shell actual tras ejecutar:
  source ~/.bashrc

Cierra sesión Hyprland e inicia i3 para el entorno gráfico completo.

También aplica tmux (classic|gray), cava y copyq según tema i3 en config.toml.
EOF
}

for arg in "$@"; do
  case "$arg" in
    -h | --help) usage; exit 0 ;;
    *) echo "Opción desconocida: $arg" >&2; usage >&2; exit 1 ;;
  esac
done

write_session_mode x11

stop_wayland_session_processes

if [ ! -f "$BASH_X11" ]; then
  echo "Error: no se encontró $BASH_X11" >&2
  exit 1
fi

cp "$BASH_X11" "${HOME}/.bashrc"
echo "Bash: bashrc.x11 → ~/.bashrc"

write_x11_env
if ! activate_i3_theme_profile; then
  activate_x11_shared_themes || true
fi
propagate_env_from_file

# Aplicar en la shell que invoca el script (si es interactiva)
# shellcheck disable=SC1091
[ -f "${HOME}/.config/bash/env.active.sh" ] && source "${HOME}/.config/bash/env.active.sh"

echo
echo "Perfil X11/i3 activo. Atajos i3: ~/.config/i3/ o Games/configurations/I3/i3-wm/"
echo "Tmux atajos: ${SCRIPT_DIR}/tmux-atajos.sh"
