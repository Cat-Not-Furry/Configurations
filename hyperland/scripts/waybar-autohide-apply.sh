#!/usr/bin/env bash
# Aplica modo normal/autohide fuera del proceso Waybar (evita que killall corte el toggle).
set -euo pipefail

target="${1:-}"
if [ "$target" != "normal" ] && [ "$target" != "autohide" ]; then
  echo "Uso: $(basename "$0") {normal|autohide}" >&2
  exit 1
fi

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib/project-paths.sh
source "$SCRIPT_DIR/lib/project-paths.sh"
resolve_project_paths "$SCRIPT_DIR"
# shellcheck source=lib/waybar-autohide.sh
source "$SCRIPT_DIR/lib/waybar-autohide.sh"
# shellcheck source=lib/service-reload.sh
source "$SCRIPT_DIR/lib/service-reload.sh"

export REPO_WAYBAR_CONFIG="$CONFIG_ROOT/waybar/config"

if [ "$target" = "autohide" ]; then
  apply_autohide_active "$(read_waybar_position)"
else
  apply_autohide_normal
fi
