#!/bin/bash

# Ruta al archivo de brillo de la retroiluminación.
# Cambia según tu equipo (ej. /sys/class/leds/asus::kbd_backlight/brightness)
LED_PATH="/sys/class/leds/tpacpi::kbd_backlight/brightness"

if [ ! -f "$LED_PATH" ]; then
  echo "N/A"
  exit 1
fi

current_brightness=$(cat "$LED_PATH" 2>/dev/null)

case $current_brightness in
0)
  echo ""
  ;;
1)
  echo "󰌵 50%"
  ;;
2)
  echo "󰌵 100%"
  ;;
*)
  echo "󰌶 ?"
  ;;
esac
