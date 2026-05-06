#!/bin/bash

DEVICE="tpacpi::kbd_backlight"

# --- LÓGICA PARA MOSTRAR EN WAYBAR ---
# Si no hay argumentos, mostramos el estado actual.
BRIGHTNESS=$(brightnessctl --device=$DEVICE get)
TEXT=""

# Usamos un 'case' como en tu script original para definir el texto.
case $BRIGHTNESS in
0)
  TEXT=""
  ;;
1)
  TEXT="󰌵 50%"
  ;;
2)
  TEXT="󰌵 100%"
  ;;
esac

# Imprimimos el resultado en formato JSON para Waybar.
echo "$TEXT"
