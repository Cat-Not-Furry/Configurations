#!/usr/bin/env bash
# Estética compartida de Wofi (misma que wofi-launch.sh / Super+D)

WOFI_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/wofi"

wofi_dmenu() {
  wofi \
    --conf "$WOFI_DIR/config" \
    --style "$WOFI_DIR/style.css" \
    --dmenu \
    --insensitive \
    "$@"
}
