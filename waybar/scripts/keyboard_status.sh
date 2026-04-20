#!/bin/bash

# Pega aquí el nombre exacto de tu teclado que obtuviste con "hyprctl devices"
KEYBOARD_NAME="at-translated-set-2-keyboard"

# Usamos hyprctl para leer si el dispositivo está habilitado (devuelve 1) o no (devuelve 0)
STATUS=$(hyprctl getoption device:$KEYBOARD_NAME:enabled | awk '/int:/ {print $2}')

# Verificamos si obtuvimos un valor para evitar errores
if [ -z "$STATUS" ]; then
  exit 1
fi

# Comparamos el estado y devolvemos el JSON para Waybar
if [ "$STATUS" -eq 1 ]; then
  # Habilitado
  printf '{"text": "⌨ ON", "class": "enabled"}\n'
else
  # Deshabilitado
  printf '{"text": "⌨ OFF", "class": "disabled"}\n'
fi
