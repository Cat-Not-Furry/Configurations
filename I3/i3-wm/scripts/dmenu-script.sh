#!/bin/bash

# Opciones del menú
opcion=$(echo -e " Bloquear\n󰁯 Suspender\n󱋑 Hibernar\n󰈆 Salir\n Reiniciar\n Apagar" | dmenu -i -p "Bienvenido $USER:")

case "$opcion" in
" Bloquear")
  ~/.config/i3/scripts/lock.sh
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
  if command -v loginctl >/dev/null 2>&1; then
    loginctl lock-session 2>/dev/null || ~/.config/i3/scripts/lock.sh &
  else
    ~/.config/i3/scripts/lock.sh &
  fi
  systemctl suspend
  ;;
"󱋑 Hibernar")
  if command -v loginctl >/dev/null 2>&1; then
    loginctl lock-session 2>/dev/null || ~/.config/i3/scripts/lock.sh &
  else
    ~/.config/i3/scripts/lock.sh &
  fi
  systemctl hibernate
  ;;
*)
  # Si se cierra dmenu sin seleccionar nada, no hacer nada
  ;;
esac
