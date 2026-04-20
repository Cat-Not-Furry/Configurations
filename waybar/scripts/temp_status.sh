#!/bin/bash

max_temp=0
for zone in /sys/class/thermal/thermal_zone*/temp; do
  if [ -r "$zone" ]; then
    temp=$(cat "$zone" 2>/dev/null)
    temp_c=$((temp / 1000))
    [ "$temp_c" -gt "$max_temp" ] && max_temp=$temp_c
  fi
done

if [ "$max_temp" -eq 0 ]; then
  echo "N/A"
  exit 1
fi

if [ "$max_temp" -ge 70 ]; then
  icon=""
elif [ "$max_temp" -ge 60 ]; then
  icon=""
else
  icon=""
fi

echo "$icon $max_temp°C"
