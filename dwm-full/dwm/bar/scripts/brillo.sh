#!/bin/bash
BRIGHTNESS=$(brightnessctl get)
MAX=$(brightnessctl max)
PERCENT=$((BRIGHTNESS * 100 / MAX))

if ((PERCENT <= 0)); then
  ICON=""
elif ((PERCENT <= 25)); then
  ICON=""
elif ((PERCENT <= 50)); then
  ICON=""
elif ((PERCENT <= 75)); then
  ICON=""
else
  ICON=""
fi

echo "$ICON $PERCENT%"
