#!/usr/bin/env bash
# Luz de teclado (solo lectura) — fallback i3/bumblebee cuando cnf-info no está.
# Basado en polybar/scripts/kbdlight.sh; device desde cnf-bin/config.toml [kbdlight].
set -euo pipefail

resolve_config_file() {
  if [[ -n "${CNF_BIN_CONFIG:-}" && -f "$CNF_BIN_CONFIG" ]]; then
    printf '%s\n' "$CNF_BIN_CONFIG"
    return 0
  fi
  if [[ -f "${HOME}/.config/cnf-bin/config.toml" ]]; then
    printf '%s\n' "${HOME}/.config/cnf-bin/config.toml"
    return 0
  fi
  local sibling
  for sibling in \
    "$(cd "$(dirname "${BASH_SOURCE[0]}")/../../../shared/cnf-bin" 2>/dev/null && pwd)/config.toml" \
    "$(cd "$(dirname "${BASH_SOURCE[0]}")/../../cnf-bin" 2>/dev/null && pwd)/config.toml"; do
    if [[ -f "$sibling" ]]; then
      printf '%s\n' "$sibling"
      return 0
    fi
  done
  return 1
}

read_kbd_device() {
  local file="$1"
  awk '
    /^\[kbdlight\]/ { in_sec=1; next }
    /^\[/ { in_sec=0 }
    in_sec && $1 == "device" {
      gsub(/^[^=]*=[[:space:]]*"/, "")
      gsub(/".*$/, "")
      gsub(/^[[:space:]]*/, "")
      print
      exit
    }
  ' "$file"
}

LED_DEVICE="tpacpi::kbd_backlight"
if config_file="$(resolve_config_file)"; then
  device_val="$(read_kbd_device "$config_file")"
  [[ -n "$device_val" ]] && LED_DEVICE="$device_val"
fi

LED_PATH="/sys/class/leds/${LED_DEVICE}/brightness"

if [[ ! -f "$LED_PATH" ]]; then
  exit 0
fi

current_brightness="$(cat "$LED_PATH" 2>/dev/null || echo 0)"

case "$current_brightness" in
0)
  echo ""
  ;;
1)
  echo "󰌵 50%"
  ;;
2)
  echo "󰌵 100%"
  ;;
*)
  echo "󰌶 ?"
  ;;
esac
