#!/bin/bash
if ! pgrep -x "cmus" >/dev/null; then
  echo ""
  exit
fi

STATUS=$(cmus-remote -Q 2>/dev/null | grep "status" | cut -d ' ' -f 2)
ARTIST=$(cmus-remote -Q 2>/dev/null | grep "artist" | cut -d ' ' -f 3-)
TITLE=$(cmus-remote -Q 2>/dev/null | grep "title" | cut -d ' ' -f 3-)

case "$STATUS" in
  playing) ICON="" ;;
  paused)  ICON="" ;;
  *)       ICON="" ;;
esac

if [ -n "$TITLE" ]; then
  output="$ICON $ARTIST - $TITLE"
  echo "${output:0:30}"
else
  echo "$ICON Cmus"
fi
