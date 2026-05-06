#!/bin/bash
temp=$(cat /sys/class/thermal/thermal_zone0/temp)
temp_c=$((temp / 1000))

if [ "$temp_c" -ge 70 ]; then
  icon=""
elif [ "$temp_c" -ge 60 ]; then
  icon=""
else
  icon=""
fi

# Imprime directamente el texto, sin JSON
echo "$icon $temp_c°C"
