#!/usr/bin/env bash
# Repara activación D-Bus de blueman-manager (clic izquierdo en applet i3).
# Uso: ~/.config/i3/scripts/blueman-dbus-env.sh
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

for session in \
  "${HOME}/.config/hypr/scripts/lib/session-env.sh" \
  "$SCRIPT_DIR/../../../hyprland/hyperland/scripts/lib/session-env.sh"; do
  if [[ -f "$session" ]]; then
    # shellcheck source=/dev/null
    source "$session"
    write_x11_env
    ensure_dbus_graphical_activation x11
    echo "OK: entorno D-Bus gráfico actualizado para blueman-manager."
    echo "Prueba clic izquierdo en el applet Bluetooth."
    exit 0
  fi
done

echo "blueman-dbus-env: session-env.sh no encontrado" >&2
exit 1
