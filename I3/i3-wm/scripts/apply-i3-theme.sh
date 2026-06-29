#!/usr/bin/env bash
# Tema i3: copia estática themes/{classic,iceberg}.conf → 07-gaps_borders.conf
# y bumblebee-bar-{tema}.conf → 05-bbar.conf (si bumblebee activo).
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
I3_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
THEMES_DIR="$I3_ROOT/conf.d/themes"
GAPS_FILE="$I3_ROOT/conf.d/07-gaps_borders.conf"
BBAR_FILE="$I3_ROOT/conf.d/05-bbar.conf"
MODE_FILE="${XDG_CACHE_HOME:-$HOME/.cache}/i3/status-bar-mode"
POLYBAR_DIR="${HOME}/.config/polybar"
NO_RELOAD=0

usage() {
  cat <<EOF
Uso: $(basename "$0") [--no-reload] [classic|iceberg]

  Reemplaza conf.d/07-gaps_borders.conf y (bumblebee) conf.d/05-bbar.conf
  desde conf.d/themes/{classic,iceberg}.conf

  Tema por defecto: [i3] theme en cnf-bin/config.toml
EOF
}

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
  sibling="$(cd "$SCRIPT_DIR/../../../shared/cnf-bin" 2>/dev/null && pwd)/config.toml"
  if [[ -f "$sibling" ]]; then
    printf '%s\n' "$sibling"
    return 0
  fi
  sibling="$(cd "$SCRIPT_DIR/../../cnf-bin" 2>/dev/null && pwd)/config.toml"
  [[ -f "$sibling" ]] && printf '%s\n' "$sibling" && return 0
  return 1
}

read_i3_theme_from_toml() {
  local file="$1"
  awk '
    /^\[i3\]/ { in_sec=1; next }
    /^\[/ { in_sec=0 }
    in_sec && $1 == "theme" {
      gsub(/^[^=]*=[[:space:]]*"/, "")
      gsub(/".*$/, "")
      gsub(/^[[:space:]]*/, "")
      print
      exit
    }
  ' "$file"
}

resolve_theme() {
  local explicit="${1:-}"
  local from_toml="" config_file="" local_file=""

  if [[ -n "$explicit" ]]; then
    printf '%s\n' "$explicit"
    return 0
  fi

  if config_file="$(resolve_config_file)"; then
    from_toml="$(read_i3_theme_from_toml "$config_file")"
    local_file="${config_file%.toml}.local.toml"
    if [[ -f "$local_file" ]]; then
      local from_local
      from_local="$(read_i3_theme_from_toml "$local_file")"
      [[ -n "$from_local" ]] && from_toml="$from_local"
    fi
  fi

  printf '%s\n' "${from_toml:-classic}"
}

polybar_active() {
  if [[ -f "$MODE_FILE" ]] && [[ "$(tr -d '[:space:]' <"$MODE_FILE")" = polybar ]]; then
    return 0
  fi
  pgrep -x polybar >/dev/null 2>&1
}

apply_polybar_theme() {
  local theme="$1"
  local src dest="$POLYBAR_DIR/config.ini"

  for src in \
    "$POLYBAR_DIR/config.${theme}.ini" \
    "$(cd "$SCRIPT_DIR/../../polybar" 2>/dev/null && pwd)/config.${theme}.ini"; do
    if [[ -f "$src" ]]; then
      cp "$src" "$dest"
      if [[ -x "$POLYBAR_DIR/launch.sh" ]]; then
        "$POLYBAR_DIR/launch.sh" &
      fi
      echo "polybar: config.${theme}.ini → config.ini"
      return 0
    fi
  done
  echo "apply-i3-theme: falta config.${theme}.ini" >&2
  return 1
}

apply_theme_files() {
  local theme="$1"
  local gaps_src="$THEMES_DIR/${theme}.conf"
  local bar_src="$THEMES_DIR/bumblebee-bar-${theme}.conf"

  [[ -f "$gaps_src" ]] || {
    echo "apply-i3-theme: falta $gaps_src" >&2
    exit 1
  }

  cp "$gaps_src" "$GAPS_FILE"
  echo "i3: 07-gaps_borders.conf ← themes/${theme}.conf"

  if polybar_active; then
    apply_polybar_theme "$theme" || true
    return 0
  fi

  [[ -f "$bar_src" ]] || {
    echo "apply-i3-theme: falta $bar_src" >&2
    exit 1
  }

  cp "$bar_src" "$BBAR_FILE"
  cp "$bar_src" "$I3_ROOT/conf.d/bar-mode/bumblebee.conf"
  cp "$bar_src" "$I3_ROOT/conf.d/bar-mode/active.conf"
  echo "i3: 05-bbar.conf ← bumblebee-bar-${theme}.conf"
}

reload_i3() {
  [[ "$NO_RELOAD" -eq 0 ]] \
    && command -v i3-msg >/dev/null 2>&1 \
    && [[ -n "${DISPLAY:-}" ]] \
    && pgrep -x i3 >/dev/null 2>&1 \
    || return 0

  echo "i3: reinicio para aplicar tema"
  i3-msg restart 2>/dev/null || i3-msg reload 2>/dev/null || true
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --no-reload) NO_RELOAD=1; shift ;;
    -h | --help) usage; exit 0 ;;
    classic | iceberg) THEME_ARG="$1"; shift ;;
    *)
      echo "Opción desconocida: $1" >&2
      usage >&2
      exit 1
      ;;
  esac
done

THEME="$(resolve_theme "${THEME_ARG:-}")"

case "$THEME" in
  classic | iceberg) ;;
  *)
    echo "Tema desconocido: $THEME (usa classic o iceberg)" >&2
    exit 1
    ;;
esac

apply_theme_files "$THEME"
reload_i3
