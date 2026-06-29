#!/usr/bin/env bash
# Generación: copyq/themes/{slug}.ini desde palettes.json (bloque waybar).
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib/project-paths.sh
source "$SCRIPT_DIR/lib/project-paths.sh"
resolve_project_paths "$SCRIPT_DIR"
# shellcheck source=lib/copyq-theme.sh
source "$SCRIPT_DIR/lib/copyq-theme.sh"

regenerate_copyq_themes 0
