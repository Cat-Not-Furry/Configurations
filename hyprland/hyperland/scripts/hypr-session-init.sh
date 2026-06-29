#!/usr/bin/env bash
# Arranque Hyprland (exec-once): limpia restos X11/i3 y aplica env Wayland a la sesión.
# No modifica ~/.bashrc (eso lo hace hypr-environment.sh vía SDM o manual).
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib/project-paths.sh
source "$SCRIPT_DIR/lib/project-paths.sh"
resolve_project_paths "$SCRIPT_DIR"
# shellcheck source=lib/session-env.sh
source "$SCRIPT_DIR/lib/session-env.sh"

stop_x11_session_processes
write_session_mode hyprland
write_hypr_env
propagate_env_from_file
sleep 0.3
start_wayland_session_services
