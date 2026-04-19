#!/bin/bash

if ! pgrep -x "cmus" >/dev/null; then
  echo ""
  exit
fi

STATUS=$(cmus-remote -Q 2>/dev/null | grep "status" | cut -d ' ' -f 2)
ARTIST=$(cmus-remote -Q 2>/dev/null | grep "artist" | cut -d ' ' -f 3-)
TITLE=$(cmus-remote -Q 2>/dev/null | grep "title" | cut -d ' ' -f 3-)

if [ "$STATUS" = "playing" ]; then
  ICON="" # Play icon
elif [ "$STATUS" = "paused" ]; then
  ICON="" # Pause icon
else
  ICON="" # Stop icon
fi

if [ -n "$TITLE" ]; then
  # Limita la salida a 60 caracteres (incluye ícono, artista y título)
  output="$ICON $ARTIST - $TITLE"
  echo "${output:0:20}"
else
  echo "$ICON Cmus"
fi
