#!/bin/bash

# --- CONFIGURACIÓN ---
# Pega aquí el nombre exacto de tu teclado obtenido con "xinput list"
KEYBOARD_NAME="AT Translated Set 2 keyboard"
# ---------------------

# Colores (ajusta si es necesario)
COLOR_ACTIVO="#84A0C6"
COLOR_INACTIVO="#ff5555"

# Revisa si el dispositivo está habilitado
IS_ENABLED=$(xinput list-props "$KEYBOARD_NAME" | grep "Device Enabled" | awk '{print $4}')

if [ "$IS_ENABLED" -eq 1 ]; then
  # Habilitado: Muestra ON
  echo "%{F$COLOR_ACTIVO}⌨ ON%{F-}"
else
  # Deshabilitado: Muestra OFF
  echo "%{F$COLOR_INACTIVO}⌨ OFF%{F-}"
fi
