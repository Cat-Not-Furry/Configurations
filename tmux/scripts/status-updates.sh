#!/usr/bin/env bash
# Contadores de actualizaciones para la status bar de tmux (cache 1 h).
set -euo pipefail

CACHE="${XDG_CACHE_HOME:-$HOME/.cache}/tmux/pkg-updates"
MAX_AGE=3600
LOCK="${CACHE}.lock"

mkdir -p "$(dirname "$CACHE")"

refresh() {
  local pac=0 aur=0 flat=0 n

  if command -v checkupdates >/dev/null 2>&1; then
    n="$(checkupdates 2>/dev/null | wc -l)"
    pac="${n// /}"
  fi
  if command -v yay >/dev/null 2>&1; then
    n="$(yay -Qu 2>/dev/null | wc -l)"
    aur="${n// /}"
  elif command -v paru >/dev/null 2>&1; then
    n="$(paru -Qu 2>/dev/null | wc -l)"
    aur="${n// /}"
  fi
  if command -v flatpak >/dev/null 2>&1; then
    n="$(flatpak remote-ls --updates 2>/dev/null | wc -l)"
    flat="${n// /}"
  fi

  printf 'pac:%s aur:%s flat:%s\n' "$pac" "$aur" "$flat" >"$CACHE"
}

cache_age() {
  if [ ! -f "$CACHE" ]; then
    echo 999999
    return
  fi
  echo $(($(date +%s) - $(stat -c %Y "$CACHE" 2>/dev/null || echo 0)))
}

if [ ! -f "$CACHE" ] || [ "$(cache_age)" -ge "$MAX_AGE" ]; then
  if mkdir "$LOCK" 2>/dev/null; then
    ( refresh; rmdir "$LOCK" 2>/dev/null ) &
  fi
fi

if [ ! -f "$CACHE" ]; then
  printf 'pac:… aur:… flat:…'
  exit 0
fi

read -r line <"$CACHE" || true
pac="${line#*pac:}"; pac="${pac%% *}"; pac="${pac%%aur:*}"
aur="${line#*aur:}"; aur="${aur%% *}"; aur="${aur%%flat:*}"
flat="${line#*flat:}"; flat="${flat%% *}"

printf 'pac:%s aur:%s flat:%s' "${pac:-0}" "${aur:-0}" "${flat:-0}"
