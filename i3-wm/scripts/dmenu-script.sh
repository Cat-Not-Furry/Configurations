#!/bin/bash

# Opciones del menú
opcion=$(echo -e " Bloquear\n󰁯 Suspender\n󱋑 Hibernar\n󰈆 Salir\n Reiniciar\n Apagar" | dmenu -i -p "Bienvenido $USER:")

case "$opcion" in
" Bloquear")
  ~/.config/i3/lock.sh # o el bloqueador de tu preferencia
  ;;
"󰈆 Salir")
  i3-msg exit
  ;;
" Reiniciar")
  reboot
  ;;
" Apagar")
  poweroff
  ;;
"󰁯 Suspender")
  ~/.config/i3/lock.sh &
  systemctl suspend
  ;;
"󱋑 Hibernar")
  ~/.config/i3/lock.sh &
  systemctl hibernate
  ;;
*)
  # Si se cierra dmenu sin seleccionar nada, no hacer nada
  ;;
esac
