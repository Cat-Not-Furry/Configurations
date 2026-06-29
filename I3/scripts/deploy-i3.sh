#!/usr/bin/env bash
# Despliegue stack i3 (X11): I3/ + shared/ → ~/.config/
# Preferir: ./I3/scripts/install-i3.sh [--binaries]
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"

resolve_deploy_script() {
  local candidate
  for candidate in \
    "$REPO_ROOT/deploy-configs.sh" \
    "$REPO_ROOT/hyprland/hyperland/scripts/deploy-configs.sh" \
    "$REPO_ROOT/hyperland/scripts/deploy-configs.sh"; do
    if [[ -f "$candidate" ]]; then
      printf '%s\n' "$candidate"
      return 0
    fi
  done
  return 1
}

DEPLOY=""
DEPLOY="$(resolve_deploy_script)" || {
  echo "deploy-i3: no se encontró deploy-configs.sh" >&2
  exit 1
}

if [[ -x "$DEPLOY" ]]; then
  exec "$DEPLOY" --config-i3 "$@"
fi
exec bash "$DEPLOY" --config-i3 "$@"
