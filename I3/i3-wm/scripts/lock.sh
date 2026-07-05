#!/usr/bin/env bash
# Bloqueo de sesión i3: loginctl (paridad hypridle) con fallback a i3lock temático.
set -euo pipefail

lock_session_user() {
  local u
  for u in "${SUDO_USER:-}" "${LOGNAME:-}" "${USER:-}"; do
    if [ -n "$u" ] && [ "$u" != root ]; then
      printf '%s\n' "$u"
      return 0
    fi
  done
  who 2>/dev/null | awk '/\(:[0-9]+\)/ {print $1; exit}'
}

# i3/xss-lock como root hace que i3lock pida la contraseña de root, no la del usuario.
if [ "$(id -u)" -eq 0 ]; then
  session_user="$(lock_session_user || true)"
  if [ -n "$session_user" ] && [ "$session_user" != root ]; then
    session_home="$(getent passwd "$session_user" | cut -d: -f6)"
    exec runuser -u "$session_user" -- \
      env DISPLAY="${DISPLAY:-:0}" \
      XAUTHORITY="${XAUTHORITY:-$session_home/.Xauthority}" \
      HOME="$session_home" \
      USER="$session_user" LOGNAME="$session_user" \
      "$0" "$@"
  fi
  echo "lock.sh: no debe ejecutarse como root (no se pudo resolver usuario de sesión)." >&2
  exit 1
fi

# Evitar dos lockers visibles a la vez.
if pgrep -x i3lock >/dev/null 2>&1; then
  exit 0
fi

lock_via_loginctl() {
  command -v loginctl >/dev/null 2>&1 || return 1
  loginctl lock-session 2>/dev/null
}

lock_via_i3lock() {
  local SCRIPT_DIR THEME
  SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
  # shellcheck source=i3-theme-lib.sh
  source "$SCRIPT_DIR/i3-theme-lib.sh"

  THEME="$(resolve_i3_theme "$SCRIPT_DIR")"

  local BAR_COLOR KEYHL_COLOR TIME_COLOR DATE_COLOR RING_WRONG
  case "$THEME" in
    iceberg)
      BAR_COLOR="161821ff"
      KEYHL_COLOR="e2e4eaff"
      TIME_COLOR="565f75ff"
      DATE_COLOR="3d4455ff"
      RING_WRONG="e27878ff"
      ;;
    classic | *)
      BAR_COLOR="99ccffff"
      KEYHL_COLOR="cce5ffff"
      TIME_COLOR="99ccffff"
      DATE_COLOR="cce5ffff"
      RING_WRONG="900000ff"
      ;;
  esac

  exec i3lock \
    --blur 5 \
    --bar-indicator \
    --bar-pos x+225:y+h-460 \
    --bar-direction 1 \
    --bar-max-height 250 \
    --bar-color="$BAR_COLOR" \
    --keyhl-color="$KEYHL_COLOR" \
    --bar-total-width 1500 \
    --bar-periodic-step 20 \
    --bar-orientation horizontal \
    --redraw-thread \
    --clock \
    --time-str="%H:%M:%S" \
    --time-pos x+950:y+h-350 \
    --time-color="$TIME_COLOR" \
    --time-size=100 \
    --date-size=50 \
    --date-pos x+950:y+h-300 \
    --date-color="$DATE_COLOR" \
    --verif-text="Verificando" \
    --wrong-text="Incorrecto" \
    --wrong-size=50 \
    --noinput-text="" \
    --insidever-color=00000000 \
    --insidewrong-color=00000000 \
    --ringver-color=00000000 \
    --ringwrong-color="$RING_WRONG" \
    --separator-color=00000000 \
    --verif-color=ffffffff \
    --wrong-color=ffffffff
}

if lock_via_loginctl; then
  exit 0
fi

lock_via_i3lock
