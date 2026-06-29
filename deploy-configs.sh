#!/usr/bin/env bash
# Despliegue maestro de dotfiles → ~/.config/ (+ mirror opcional al repo).
# Punto de entrada en la raíz del repo; implementación en hyprland/hyperland/scripts/.
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

for candidate in \
  "$ROOT/hyprland/hyperland/scripts/deploy-configs.sh" \
  "$ROOT/hyperland/scripts/deploy-configs.sh"; do
  if [[ -x "$candidate" ]]; then
    exec "$candidate" "$@"
  fi
done

echo "deploy-configs: no se encontró hyprland/hyperland/scripts/deploy-configs.sh" >&2
exit 1
