#!/bin/bash
if ! pgrep -x "cmus" >/dev/null; then
  echo ""
  exit
fi

STATUS=$(cmus-remote -Q | grep "status" | cut -d ' ' -f 2)

if [ "$STATUS" = "playing" ]; then
  ICON=""
elif [ "$STATUS" = "paused" ]; then
  ICON=""
else
  ICON=""
fi
echo "$ICON"
