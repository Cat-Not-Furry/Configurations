#!/usr/bin/env bash
STATE_FILE="${HOME}/.cache/hypr/waybar-position.json"

position="top"
if [ -f "$STATE_FILE" ]; then
  position=$(python3 -c "
import json
from pathlib import Path
p = Path('$STATE_FILE')
try:
    print(json.loads(p.read_text()).get('position', 'top'))
except Exception:
    print('top')
" 2>/dev/null || echo "top")
fi

if [ "$position" = "bottom" ]; then
  printf '↑'
else
  printf '↓'
fi
