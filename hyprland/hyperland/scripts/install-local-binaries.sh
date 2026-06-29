#!/usr/bin/env bash
# Instala binarios cnf-bin + wb_autohide + utilidades en /usr/local/bin.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib/project-paths.sh
source "$SCRIPT_DIR/lib/project-paths.sh"
resolve_project_paths "$SCRIPT_DIR"

CNF_BIN_SRC="${CNF_BIN_ROOT:-$CONFIG_ROOT/cnf-bin}/bin"
UTIL_SRC="$(path_shared utilidades)"
WB_SRC="$(path_hyprland_component waybar)/scripts/bin/wb_autohide"

install -d /usr/local/bin

if [[ -d "$CNF_BIN_SRC" ]]; then
  echo "Instalando cnf-bin/bin → /usr/local/bin"
  install -m 755 "$CNF_BIN_SRC"/* /usr/local/bin/ 2>/dev/null || true
else
  echo "Warning: no existe $CNF_BIN_SRC" >&2
fi

for u in monitor monitor-wofi cpu-mode emulator-manager network-scanner.sh; do
  if [[ -x "$UTIL_SRC/$u" ]]; then
    install -m 755 "$UTIL_SRC/$u" "/usr/local/bin/$u"
    echo "Instalado: $u"
  fi
done

if [[ -x "$WB_SRC" ]]; then
  install -m 755 "$WB_SRC" /usr/local/bin/wb_autohide
  echo "Instalado: wb_autohide"
elif [[ -f "$CONFIG_ROOT/waybar_auto_hide/target/release/wb_autohide" ]]; then
  install -m 755 "$CONFIG_ROOT/waybar_auto_hide/target/release/wb_autohide" /usr/local/bin/wb_autohide
  echo "Instalado: wb_autohide (desde target/release)"
else
  echo "Warning: wb_autohide no encontrado; compila waybar_auto_hide" >&2
fi

echo "Listo. Verifica: which cnf-info cnf-media wb_autohide sdm"
