#!/bin/bash

# Verifica si el primer argumento es "1" (que Polybar envía para un clic izquierdo)
if [ "$1" == "1" ]; then
  WINDOW_NAME="calendar_window"
  eww open --toggle $WINDOW_NAME
fi

exit 0
