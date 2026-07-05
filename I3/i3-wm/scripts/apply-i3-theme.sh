#!/usr/bin/env bash
# Tema i3: copia themes/{classic,iceberg}.conf → 07-gaps_borders.conf
# y bumblebee-bar-{tema}.conf → 05-bbar.conf (si bumblebee activo).
# Sincroniza [i3] y [bumblebee] theme en config.local.toml.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=../../../shared/cnf-bin/lib/require-session-user.sh
source "${HOME}/.config/cnf-bin/lib/require-session-user.sh" 2>/dev/null \
  || source "$SCRIPT_DIR/../../../shared/cnf-bin/lib/require-session-user.sh"
require_session_user "$0" "$@"
# shellcheck source=i3-theme-lib.sh
source "$SCRIPT_DIR/i3-theme-lib.sh"

I3_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
if [[ -d "${HOME}/.config/i3/conf.d/themes" ]]; then
  I3_ROOT="${HOME}/.config/i3"
fi
THEMES_DIR="$I3_ROOT/conf.d/themes"
GAPS_FILE="$I3_ROOT/conf.d/07-gaps_borders.conf"
BBAR_FILE="$I3_ROOT/conf.d/05-bbar.conf"
MODE_FILE="${XDG_CACHE_HOME:-$HOME/.cache}/i3/status-bar-mode"
POLYBAR_DIR="${HOME}/.config/polybar"
NO_RELOAD=0
THEME_ARG=""

usage() {
  cat <<EOF
Uso: $(basename "$0") [--no-reload] [classic|iceberg]

  Reemplaza conf.d/07-gaps_borders.conf y (bumblebee) conf.d/05-bbar.conf
  desde conf.d/themes/{classic,iceberg}.conf
  Persiste el tema en ~/.config/cnf-bin/config.local.toml ([i3] + [bumblebee])

  Tema por defecto: [i3] theme en cnf-bin/config.toml (+ override local)
EOF
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

  echo "i3: reload para aplicar tema ($THEME)"
  i3-msg reload 2>/dev/null || true
  sleep 0.3
  ensure_single_i3bar
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

THEME="$(resolve_i3_theme "$SCRIPT_DIR" "${THEME_ARG:-}")"

case "$THEME" in
  classic | iceberg) ;;
  *)
    echo "Tema desconocido: $THEME (usa classic o iceberg)" >&2
    exit 1
    ;;
esac

if [[ ! -f "$I3_ROOT/conf.d/07-gaps_borders.conf" ]]; then
  echo "apply-i3-theme: no existe $GAPS_FILE" >&2
  exit 1
fi

persist_i3_theme_config "$THEME"
echo "cnf-bin: config.local.toml ← [i3] theme=${THEME}, [bumblebee] theme=$(bumblebee_theme_for_i3 "$THEME")"

apply_theme_files "$THEME"
activate_nvim_for_i3_theme "$THEME" "$SCRIPT_DIR" || true

_load_session_env_for_x11_themes() {
  local candidate
  for candidate in \
    "${HOME}/.config/hypr/scripts/lib/session-env.sh" \
    "$SCRIPT_DIR/../../../hyprland/hyperland/scripts/lib/session-env.sh" \
    "$SCRIPT_DIR/../../hyperland/scripts/lib/session-env.sh"; do
    if [[ -f "$candidate" ]]; then
      # shellcheck source=/dev/null
      source "$candidate"
      return 0
    fi
  done
  return 1
}

if _load_session_env_for_x11_themes; then
  activate_x11_shared_themes "$THEME" || true
fi

reload_i3
