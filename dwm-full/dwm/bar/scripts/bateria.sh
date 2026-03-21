#!/bin/bash
BAT_PATH=$(find /sys/class/power_supply -name "BAT*" | head -n1)
if [ -z "$BAT_PATH" ]; then
  echo "󰂎 ?"
  exit
fi

capacity=$(cat "$BAT_PATH/capacity" 2>/dev/null)
status=$(cat "$BAT_PATH/status" 2>/dev/null)

if [ "$status" = "Charging" ]; then
  echo " $capacity%"
elif [ "$status" = "Discharging" ]; then
  echo " $capacity%"
else
  echo "󰂎 $capacity%"
fi
