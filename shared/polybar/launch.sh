#!/bin/bash

# Terminar instancias de barras que ya se estén ejecutando
killall -q polybar

# Esperar a que los procesos se cierren
while pgrep -u $UID -x polybar >/dev/null; do sleep 1; done

# Lanzar Polybar, usando la configuración por defecto en ~/.config/polybar/config.ini
polybar mybar &

echo "Polybar lanzada..."
