#!/usr/bin/env bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib/wofi-common.sh
source "$SCRIPT_DIR/lib/wofi-common.sh"

opcion=$(echo -e " Bloquear\n󰁯 Suspender\n󰈆 Salir\n Reiniciar\n Apagar" | wofi_dmenu --prompt "Apagado — $USER:")

case "$opcion" in
" Bloquear")
  hyprlock
  ;;
"󰈆 Salir")
  hyprctl dispatch exit
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
*)
  ;;
esac
