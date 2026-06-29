#!/usr/bin/env bash
set -euo pipefail

target="${1:-all}"

count_pacman() {
  if command -v checkupdates >/dev/null 2>&1; then
    checkupdates 2>/dev/null | wc -l
  else
    pacman -Qu 2>/dev/null | wc -l
  fi
}

count_aur() {
  if command -v yay >/dev/null 2>&1; then
    yay -Qua 2>/dev/null | wc -l
  else
    echo 0
  fi
}

count_flatpak() {
  if command -v flatpak >/dev/null 2>&1; then
    flatpak remote-ls --updates 2>/dev/null | wc -l
  else
    echo 0
  fi
}

case "$target" in
  pacman) count_pacman | tr -d ' ' ;;
  aur) count_aur | tr -d ' ' ;;
  flatpak) count_flatpak | tr -d ' ' ;;
  all)
    printf '{"pacman":%s,"aur":%s,"flatpak":%s}\n' \
      "$(count_pacman | tr -d ' ')" \
      "$(count_aur | tr -d ' ')" \
      "$(count_flatpak | tr -d ' ')"
    ;;
  *) echo 0 ;;
esac
