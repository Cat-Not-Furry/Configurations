#!/bin/bash

COLOR_NORMAL="#84A0C6"
COLOR_WARNING="#fba922"
COLOR_CRITICAL="#ff5555"

max_temp=0
max_zone=""

# Buscar todas las zonas térmicas en /sys/class/thermal
for zone in /sys/class/thermal/thermal_zone*/temp; do
  if [ -r "$zone" ]; then
    temp=$(cat "$zone" 2>/dev/null)
    if [ -n "$temp" ]; then
      temp_c=$((temp / 1000))
      if [ "$temp_c" -gt "$max_temp" ]; then
        max_temp=$temp_c
        max_zone=$(basename "$zone")
      fi
    fi
  fi
done

if [ "$max_temp" -eq 0 ]; then
  echo "N/A"
  exit 1
fi

# Lógica de íconos y colores
if [ "$max_temp" -ge 70 ]; then
  icon=""
  color="$COLOR_CRITICAL"
elif [ "$max_temp" -ge 60 ]; then
  icon=""
  color="$COLOR_WARNING"
elif [ "$max_temp" -ge 45 ]; then
  icon=""
  color="$COLOR_NORMAL"
elif [ "$max_temp" -ge 35 ]; then
  icon=""
  color="$COLOR_NORMAL"
else
  icon=""
  color="$COLOR_NORMAL"
fi

echo "%{F$color}$icon $max_temp°C%{F-}"
