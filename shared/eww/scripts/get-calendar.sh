#!/usr/bin/env bash
set -euo pipefail

TODAY=$(date +%-d)
TODAY_COLOR="#50fa7b"

header=$(LC_TIME=es_ES.UTF-8 date +"%B %Y" 2>/dev/null || date +"%B %Y")
header="${header^}"

body=$(cal | sed "s/\b${TODAY}\b/<b><span foreground='${TODAY_COLOR}'>${TODAY}<\/span><\/b>/g")

printf '<span size="large" weight="bold">%s</span>\n\n%s' "$header" "$body"
