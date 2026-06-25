#!/usr/bin/env bash
# Cierra overview + submap + cache en un solo paso (evita doble Esc).
set -euo pipefail

CACHE="${XDG_CACHE_HOME:-$HOME/.cache}/hyprexpo/nav-active"

hyprctl dispatch hyprexpo:expo cancel 2>/dev/null || true
hyprctl dispatch hyprexpo:expo off 2>/dev/null || true
hyprctl dispatch submap reset 2>/dev/null || true
rm -f "$CACHE"
