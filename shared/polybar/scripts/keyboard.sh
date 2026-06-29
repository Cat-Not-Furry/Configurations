#!/bin/bash
# ~/.config/polybar/scripts/keyboard-status

DEVICE="AT Translated Set 2 keyboard"
DEVICE_ID=$(xinput list --id-only "$DEVICE" 2>/dev/null)

if [ -z "$DEVICE_ID" ]; then
  echo "N/A"
  exit 1
fi

# Dentro de keyboard-status
if xinput list | grep "id=$DEVICE_ID" | grep -qi floating; then
  echo "%{F#ff5555}OFF%{F-}"
else
  echo "%{F#84A0C6}ON%{F-}"
fi
