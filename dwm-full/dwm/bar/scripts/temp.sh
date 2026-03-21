#!/bin/bash
temp=$(sensors | grep "Core 0" | awk '{print $3}' | tr -d '+°C')
temp_num=$(echo "$temp" | sed 's/[^0-9.]//g')

if (($(echo "$temp_num <= 40" | bc -l))); then
  ICON=""
elif (($(echo "$temp_num <= 55" | bc -l))); then
  ICON=""
elif (($(echo "$temp_num <= 70" | bc -l))); then
  ICON=""
else
  ICON=""
fi

echo "$ICON $temp_num°C"
