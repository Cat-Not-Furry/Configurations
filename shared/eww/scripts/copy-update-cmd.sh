#!/usr/bin/env bash
set -euo pipefail

target="${1:-}"

case "$target" in
  pacman) cmd="sudo pacman -Syu" ;;
  aur) cmd="yay -Syu" ;;
  flatpak) cmd="flatpak update" ;;
  *)
    exit 1
    ;;
esac

if command -v wl-copy >/dev/null 2>&1; then
  printf '%s' "$cmd" | wl-copy
elif command -v copyq >/dev/null 2>&1; then
  copyq copy "$cmd"
else
  printf '%s' "$cmd" | xclip -selection clipboard 2>/dev/null || true
fi

if command -v notify-send >/dev/null 2>&1; then
  notify-send -t 2500 "Copiado: $cmd"
fi
