#!/usr/bin/env bash
# Lanza bumblebee-status leyendo cnf-bin/config.toml (tema + módulos).
# Añade shell:kbd → cnf-info --kbdlight (solo lectura).
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
  sibling="$(cd "$SCRIPT_DIR/.." && pwd)/cnf-bin/config.toml"
  if [[ -f "$sibling" ]]; then
    printf '%s\n' "$sibling"
    return 0
  fi
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
MODULES="media cpu sensors memory disk battery pipewire brightness keyboard hostname datetime"

if CONFIG_FILE="$(resolve_config_file)"; then
  theme_val="$(read_bumblebee_value "$CONFIG_FILE" theme)"
  modules_val="$(read_bumblebee_value "$CONFIG_FILE" modules)"
  [[ -n "$theme_val" ]] && THEME="$theme_val"
  [[ -n "$modules_val" ]] && MODULES="$modules_val"
fi

MODULES="$MODULES shell:kbd"

CNF_INFO="cnf-info"
if ! command -v cnf-info >/dev/null 2>&1; then
  if [[ -x /usr/local/bin/cnf-info ]]; then
    CNF_INFO="/usr/local/bin/cnf-info"
  elif [[ -x "${SCRIPT_DIR}/../cnf-bin/bin/cnf-info" ]]; then
    CNF_INFO="$(cd "$SCRIPT_DIR/../cnf-bin/bin" && pwd)/cnf-info"
  fi
fi

exec "$BB_BIN" \
  -t "$THEME" \
  -m $MODULES \
  -p "shell:kbd.command=${CNF_INFO} --kbdlight" \
  -p 'shell:kbd.interval=10s'
