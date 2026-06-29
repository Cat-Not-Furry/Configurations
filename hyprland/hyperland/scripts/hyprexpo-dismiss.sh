#!/usr/bin/env bash
# Cierra hyprexpo antes de desmapear ventanas (Super+C, Super+X, etc.).
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
"$SCRIPT_DIR/hyprexpo-exit.sh"
