#!/bin/bash

# Opciones del menú, la misma cadena de texto.
opcion=$(echo -e " Bloquear\n󰁯 Suspender\n󱋑 Hibernar\n󰈆 Salir\n Reiniciar\n Apagar" | wofi --dmenu --insensitive --prompt "Bienvenido $USER:")

case "$opcion" in
" Bloquear")
  hyprlock # o el bloqueador de tu preferencia [cite: 1]
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
  # Si se cierra wofi sin seleccionar nada, no hacer nada [cite: 5]
  ;;
esac
