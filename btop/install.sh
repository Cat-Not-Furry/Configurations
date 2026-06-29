#!/usr/bin/env bash
# Instala la configuración de btop en ~/.config/btop/
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DEST="${XDG_CONFIG_HOME:-$HOME/.config}/btop"

usage() {
  cat <<EOF
Uso: $(basename "$0")

Copia btop.conf a $DEST/btop.conf

Requisito: paquete btop (sudo pacman -S btop)
Tema referenciado: tokyo-night ( /usr/share/btop/themes/ )

Ver: btop/README.md
EOF
}

[[ "${1:-}" == "-h" || "${1:-}" == "--help" ]] && { usage; exit 0; }

mkdir -p "$DEST"
install -m 644 "$SCRIPT_DIR/btop.conf" "$DEST/btop.conf"
echo "Instalado: $DEST/btop.conf"
