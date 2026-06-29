#!/bin/bash

# Colores
COLOR_NORMAL="#84A0C6"
COLOR_WARNING="#fba922"
COLOR_CRITICAL="#ff5555"
ICON_NORMAL="󰾆 "
ICON_WARNING="󰾅 "
ICON_CRITICAL="󰓅 "

# Obtiene la frecuencia máxima de la CPU en GHz (primer núcleo como referencia)
cpu_full=$(awk -F': ' '/MHz/ {printf "%.1f", $2/1000; exit}' /proc/cpuinfo)
# cpu_full=$(awk '/MHz/ {sum+=$4; n++} END {printf "%.1f", sum/n/1000}' /proc/cpuinfo)
cpu_num=$cpu_full # ya en GHz

# Comparación usando awk
if awk "BEGIN {exit !($cpu_num >= 3.5)}"; then
  color="$COLOR_CRITICAL"
  icon="$ICON_CRITICAL"
elif awk "BEGIN {exit !($cpu_num >= 2.0)}"; then
  color="$COLOR_WARNING"
  icon="$ICON_WARNING"
else
  color="$COLOR_NORMAL"
  icon="$COLOR_NORMAL"
fi

echo "%{F$color}$icon${cpu_full}GHz%{F-}"
