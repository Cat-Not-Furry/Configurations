#!/usr/bin/env bash
# Variables de sesión X11/i3 al arrancar i3 (sin cambiar ~/.bashrc en cada reload).
# Paridad con hyperland/scripts/x11-environment.sh + limpieza de restos Wayland.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

load_session_libs() {
  local paths session
  for paths in \
    "${HOME}/.config/hypr/scripts/lib/project-paths.sh" \
    "$SCRIPT_DIR/../../../hyprland/hyperland/scripts/lib/project-paths.sh" \
    "$SCRIPT_DIR/../../hyperland/scripts/lib/project-paths.sh"; do
    if [ -f "$paths" ]; then
      # shellcheck source=/dev/null
      source "$paths"
      resolve_project_paths "$(cd "$(dirname "$paths")/.." && pwd)"
      break
    fi
  done

  for session in \
    "${HOME}/.config/hypr/scripts/lib/session-env.sh" \
    "$SCRIPT_DIR/../../../hyprland/hyperland/scripts/lib/session-env.sh" \
    "$SCRIPT_DIR/../../hyperland/scripts/lib/session-env.sh"; do
    if [ -f "$session" ]; then
      # shellcheck source=/dev/null
      source "$session"
      return 0
    fi
  done
  return 1
}

if ! load_session_libs; then
  echo "i3-environment: no se encontró session-env.sh" >&2
  exit 1
fi

stop_wayland_session_processes
write_session_mode x11
write_x11_env
propagate_env_from_file
activate_x11_shared_themes || true
sleep 0.3
start_x11_session_services
