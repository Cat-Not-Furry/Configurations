#!/usr/bin/env bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib/wofi-common.sh
source "$SCRIPT_DIR/lib/wofi-common.sh"

opcion=$(echo -e " Bloquear\n󰁯 Suspender\n󱋑 Hibernar\n󰈆 Salir\n Reiniciar\n Apagar" | wofi_dmenu --prompt "Bienvenido $USER:")

case "$opcion" in
" Bloquear")
  hyprlock
  ;;
"󰈆 Salir")
  killall Hyprland
  ;;
" Reiniciar")
  reboot
  ;;
" Apagar")
  poweroff
  ;;
"󰁯 Suspender")
  systemctl suspend
  ;;
"󱋑 Hibernar")
  systemctl hibernate
  ;;
*)
  ;;
esac
