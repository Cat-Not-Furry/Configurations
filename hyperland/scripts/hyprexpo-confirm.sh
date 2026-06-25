#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

hyprctl dispatch hyprexpo:kb_confirm
"$SCRIPT_DIR/hyprexpo-exit.sh"
