#!/bin/bash

DEVICE="tpacpi::kbd_backlight"
ICON="󰌵"

if [ ! -d "/sys/class/leds/$DEVICE" ]; then
  echo ""
  exit 1
fi

BRIGHTNESS=$(brightnessctl --device="$DEVICE" get 2>/dev/null)
case "$BRIGHTNESS" in
0) echo "" ;;
1) echo "$ICON 50%" ;;
2) echo "$ICON 100%" ;;
*) echo "$ICON ?" ;;
esac
