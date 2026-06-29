#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
INDEX="${1:?índice 1-10}"

hyprctl dispatch hyprexpo:kb_selecti "$INDEX"
"$SCRIPT_DIR/hyprexpo-exit.sh"
