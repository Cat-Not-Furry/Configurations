#!/bin/bash
# session-selector: elige entre i3 (X11) y Hyprland (Wayland)

# Si ya hay una sesión gráfica, salir
[ -n "$DISPLAY" ] || [ -n "$WAYLAND_DISPLAY" ] && exit 0

# Solo en terminal interactiva (evitar SSH sin -t)
[ -t 0 ] || exit 0
[ -n "$SSH_TTY" ] && exit 0

echo "Selecciona el entorno:"
echo "  (I) i3"
echo "  (H) Hyprland"
echo -n "Opción: "
read -n 1 opcion
echo

start_i3() {
  exec startx /usr/bin/i3 -- vt$(fgconsole)
}

start_hyprland() {
  local start_hypr
  if command -v start-hyprland >/dev/null 2>&1; then
    start_hypr="$(command -v start-hyprland)"
  elif [ -x /usr/bin/start-hyprland ]; then
    start_hypr=/usr/bin/start-hyprland
  else
    echo "Error: start-hyprland no encontrado (paquete hyprland)." >&2
    exit 1
  fi
  exec "$start_hypr"
}

case "$opcion" in
i | I) start_i3 ;;
h | H) start_hyprland ;;
*)
  echo "Opción inválida. Usando i3 por defecto."
  start_i3
  ;;
esac

