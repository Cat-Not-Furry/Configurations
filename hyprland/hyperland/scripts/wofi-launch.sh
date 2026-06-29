#!/usr/bin/env bash
# Lanza Wofi con config y estilo del tema activo
WOFI_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/wofi"
exec wofi \
  --conf "$WOFI_DIR/config" \
  --style "$WOFI_DIR/style.css" \
  --show drun \
  --allow-images
