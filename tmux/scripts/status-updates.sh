#!/usr/bin/env bash
# Contadores pacman / AUR / flatpak para la status bar de tmux (cache 1 h).
set -uo pipefail

CACHE="${XDG_CACHE_HOME:-$HOME/.cache}/tmux/pkg-updates"
MAX_AGE=3600
LOCK="${CACHE}.lock"
LOCK_MAX_AGE=120
PAC_TIMEOUT=900
AUR_TIMEOUT=120
FLAT_TIMEOUT=15

mkdir -p "$(dirname "$CACHE")"

count_pacman() {
  local n=0 out rc=0

  if command -v checkupdates >/dev/null 2>&1; then
    out="$(timeout "$PAC_TIMEOUT" checkupdates 2>/dev/null)" || rc=$?
    if [ "$rc" -eq 124 ]; then
      printf '?'
      return
    fi
    n="$(printf '%s\n' "$out" | sed '/^$/d' | wc -l | tr -d '[:space:]')"
    [[ "$n" =~ ^[0-9]+$ ]] || n=0
    printf '%s' "$n"
    return
  fi

  if command -v pacman >/dev/null 2>&1; then
    out="$(timeout "$PAC_TIMEOUT" pacman -Qu 2>/dev/null)" || rc=$?
    if [ "$rc" -eq 124 ]; then
      printf '?'
      return
    fi
    n="$(printf '%s\n' "$out" | sed '/^$/d' | wc -l | tr -d '[:space:]')"
    [[ "$n" =~ ^[0-9]+$ ]] || n=0
  fi
  printf '%s' "$n"
}

count_aur() {
  local out n rc=0

  if command -v yay >/dev/null 2>&1; then
    out="$(timeout "$AUR_TIMEOUT" yay -Qu --aur 2>/dev/null)" || rc=$?
  elif command -v paru >/dev/null 2>&1; then
    out="$(timeout "$AUR_TIMEOUT" paru -Qua 2>/dev/null)" || rc=$?
  else
    printf '0'
    return
  fi

  if [ "$rc" -eq 124 ] || { [ "$rc" -ne 0 ] && [ -z "$(printf '%s' "$out" | sed '/^$/d')" ]; }; then
    printf '?'
    return
  fi

  n="$(printf '%s\n' "$out" | sed '/^$/d' | wc -l | tr -d '[:space:]')"
  [[ "$n" =~ ^[0-9]+$ ]] || n=0
  printf '%s' "$n"
}

count_flatpak() {
  if command -v flatpak >/dev/null 2>&1; then
    local n rc=0 out
    out="$(timeout "$FLAT_TIMEOUT" flatpak remote-ls --updates 2>/dev/null)" || rc=$?
    if [ "$rc" -eq 124 ]; then
      printf '?'
      return
    fi
    n="$(printf '%s\n' "$out" | sed '/^$/d' | wc -l | tr -d '[:space:]')"
    [[ "$n" =~ ^[0-9]+$ ]] || n=0
    printf '%s' "$n"
  else
    printf '0'
  fi
}

refresh() {
  local pac aur flat
  pac="$(count_pacman)"
  aur="$(count_aur)"
  flat="$(count_flatpak)"
  printf 'pac:%s aur:%s flat:%s\n' "$pac" "$aur" "$flat" >"$CACHE"
}

parse_cache_field() {
  local line=$1 key=$2
  local val
  val="${line#*${key}:}"
  val="${val%% *}"
  case "$key" in
    pac) val="${val%%aur:*}" ;;
    aur) val="${val%%flat:*}" ;;
  esac
  printf '%s' "${val:-0}"
}

format_indicator() {
  local label=$1 value=$2 hi=$3
  if [ "$value" = '?' ]; then
    printf '#[fg=colour220]%s:?#[default] ' "$label"
  elif [[ "$value" =~ ^[0-9]+$ ]] && [ "$value" -gt 0 ]; then
    printf '#[fg=%s,bold]%s:%s#[default] ' "$hi" "$label" "$value"
  else
    printf '#[fg=colour245]%s:%s#[default] ' "$label" "${value:-0}"
  fi
}

format_status() {
  local pac=$1 aur=$2 flat=$3
  format_indicator pac "$pac" colour39
  format_indicator aur "$aur" colour208
  format_indicator flat "$flat" colour120
}

cache_age() {
  if [ ! -f "$CACHE" ]; then
    printf '999999'
    return
  fi
  printf '%s' "$(($(date +%s) - $(stat -c %Y "$CACHE" 2>/dev/null || echo 0)))"
}

lock_age() {
  if [ ! -d "$LOCK" ]; then
    printf '0'
    return
  fi
  printf '%s' "$(($(date +%s) - $(stat -c %Y "$LOCK" 2>/dev/null || echo 0)))"
}

if [ -d "$LOCK" ] && [ "$(lock_age)" -ge "$LOCK_MAX_AGE" ]; then
  rmdir "$LOCK" 2>/dev/null || rm -rf "$LOCK" 2>/dev/null || true
fi

if [ ! -f "$CACHE" ] || [ "$(cache_age)" -ge "$MAX_AGE" ]; then
  if mkdir "$LOCK" 2>/dev/null; then
    ( refresh; rmdir "$LOCK" 2>/dev/null ) &
  fi
fi

if [ ! -f "$CACHE" ]; then
  format_status '…' '…' '…'
  exit 0
fi

read -r line <"$CACHE" || true
pac="$(parse_cache_field "$line" pac)"
aur="$(parse_cache_field "$line" aur)"
flat="$(parse_cache_field "$line" flat)"

format_status "$pac" "$aur" "$flat"
