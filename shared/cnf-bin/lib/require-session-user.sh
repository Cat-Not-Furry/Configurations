#!/usr/bin/env bash
# Exige ejecución como usuario de sesión. Si se invocó con sudo ./script, re-lanza como SUDO_USER.

deploy_config_owner() {
  if [[ -n "${SUDO_USER:-}" && "$SUDO_USER" != root ]]; then
    printf '%s\n' "$SUDO_USER"
  else
    id -un 2>/dev/null || printf '%s\n' "${USER:-}"
  fi
}

require_session_user() {
  local script="${1:?script path requerido}"
  shift

  if [[ $EUID -eq 0 && -n "${SUDO_USER:-}" && "$SUDO_USER" != root ]]; then
    local home uid
    home="$(getent passwd "$SUDO_USER" | cut -d: -f6)"
    uid="$(getent passwd "$SUDO_USER" | cut -d: -f3)"
    exec sudo -u "$SUDO_USER" -H \
      env DISPLAY="${DISPLAY:-:0}" \
      XAUTHORITY="${XAUTHORITY:-$home/.Xauthority}" \
      DBUS_SESSION_BUS_ADDRESS="${DBUS_SESSION_BUS_ADDRESS:-unix:path=/run/user/${uid}/bus}" \
      USER="$SUDO_USER" LOGNAME="$SUDO_USER" \
      "$script" "$@"
  fi

  if [[ $EUID -eq 0 ]]; then
    echo "No ejecutes este script como root. Usa tu usuario normal." >&2
    echo "Ejemplo: $(basename "$script")   # sin sudo" >&2
    exit 1
  fi
}
