#!/usr/bin/env bash
# Encuentra require-session-user.sh y exige usuario de sesión (no ejecutar como root).
# Uso: source este archivo; luego bootstrap_session_user "$0" "$@"

bootstrap_session_user() {
  local entry="${1:?entry script}"
  shift
  local candidate here
  here="$(cd "$(dirname "$entry")" 2>/dev/null && pwd)" || here=""
  for candidate in \
    "${HOME}/.config/cnf-bin/lib/require-session-user.sh" \
    "${HOME}/Games/configurations/shared/cnf-bin/lib/require-session-user.sh" \
    "${HOME}/hyprland/cnf-bin/lib/require-session-user.sh" \
    "${here:+$here/../lib/require-session-user.sh}" \
    "${here:+$here/../../shared/cnf-bin/lib/require-session-user.sh}" \
    "${here:+$here/../../../shared/cnf-bin/lib/require-session-user.sh}"; do
    if [[ -n "$candidate" && -f "$candidate" ]]; then
      # shellcheck source=/dev/null
      source "$candidate"
      require_session_user "$entry" "$@"
      return 0
    fi
  done
  echo "require-session-user.sh no encontrado; despliega shared/cnf-bin/lib." >&2
  exit 1
}
