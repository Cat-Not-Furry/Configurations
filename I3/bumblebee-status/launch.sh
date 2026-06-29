#!/usr/bin/env bash
# Lanza bumblebee-status leyendo cnf-bin/config.toml (tema + módulos).
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BB_BIN="$SCRIPT_DIR/bumblebee-status"

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
    "$(cd "$SCRIPT_DIR/../../shared/cnf-bin" 2>/dev/null && pwd)/config.toml" \
    "$(cd "$SCRIPT_DIR/../../cnf-bin" 2>/dev/null && pwd)/config.toml"; do
    if [[ -f "$sibling" ]]; then
      printf '%s\n' "$sibling"
      return 0
    fi
  done
  return 1
}

read_bumblebee_value() {
  local file="$1" key="$2"
  awk -v section="bumblebee" -v key="$key" '
    /^\[bumblebee\]/ { in_sec=1; next }
    /^\[/ { in_sec=0 }
    in_sec && $1 == key {
      gsub(/^[^=]*=[[:space:]]*"/, "")
      gsub(/".*$/, "")
      print
      exit
    }
  ' "$file"
}

THEME="iceberg"
MODULES="media cpu sensors memory disk battery pipewire brightness kbdlight keyboard hostname datetime"

if CONFIG_FILE="$(resolve_config_file)"; then
  theme_val="$(read_bumblebee_value "$CONFIG_FILE" theme)"
  modules_val="$(read_bumblebee_value "$CONFIG_FILE" modules)"
  [[ -n "$theme_val" ]] && THEME="$theme_val"
  [[ -n "$modules_val" ]] && MODULES="$modules_val"
fi

if [[ ! -x "$BB_BIN" ]]; then
  echo "launch.sh: no ejecutable $BB_BIN" >&2
  exit 1
fi

exec "$BB_BIN" -t "$THEME" -m $MODULES
