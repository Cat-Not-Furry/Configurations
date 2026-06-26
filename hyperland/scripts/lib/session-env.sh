#!/usr/bin/env bash
# Fragmentos de entorno Hyprland (Wayland) vs X11/i3 — escrito por *-environment.sh

SESSION_MODE_FILE="${HOME}/.cache/hypr/session-mode"

write_session_mode() {
  local mode="$1"
  mkdir -p "$(dirname "$SESSION_MODE_FILE")"
  printf '%s\n' "$mode" >"$SESSION_MODE_FILE"
}

remove_legacy_config_hyprland_dir() {
  if [ ! -d "${HOME}/.config/hyprland" ]; then
    return 0
  fi
  if [ -f "${HOME}/.config/hyprland/session-mode" ] && [ ! -f "$SESSION_MODE_FILE" ]; then
    mkdir -p "$(dirname "$SESSION_MODE_FILE")"
    cp "${HOME}/.config/hyprland/session-mode" "$SESSION_MODE_FILE"
  fi
  rm -rf "${HOME}/.config/hyprland"
  echo "Eliminado legado: ~/.config/hyprland (session-mode → ~/.cache/hypr/)"
}

write_hypr_env() {
  local dest="${HOME}/.config/bash/env.active.sh"
  mkdir -p "$(dirname "$dest")"
  cat >"$dest" <<'EOF'
# Generado por hypr-environment.sh — no editar a mano
export XDG_SESSION_TYPE=wayland
export GDK_BACKEND=wayland
export QT_QPA_PLATFORM=wayland
export QT_QPA_PLATFORMTHEME=qt5ct
export XDG_CURRENT_DESKTOP=Hyprland
EOF
  echo "Entorno: perfil Hyprland → $dest"
}

write_x11_env() {
  local dest="${HOME}/.config/bash/env.active.sh"
  mkdir -p "$(dirname "$dest")"
  cat >"$dest" <<'EOF'
# Generado por x11-environment.sh / i3-environment.sh — no editar a mano
export XDG_SESSION_TYPE=x11
export GDK_BACKEND=x11
export QT_QPA_PLATFORM=xcb
export QT_QPA_PLATFORMTHEME=qt5ct
export XDG_CURRENT_DESKTOP=i3
unset WAYLAND_DISPLAY 2>/dev/null || true
EOF
  echo "Entorno: perfil X11/i3 → $dest"
}

# Propaga ~/.config/bash/env.active.sh a la sesión gráfica (no solo bash interactivo).
propagate_env_from_file() {
  local dest="${HOME}/.config/bash/env.active.sh"
  if [ ! -f "$dest" ]; then
    return 0
  fi
  # shellcheck disable=SC1090
  source "$dest"

  if ! command -v dbus-update-activation-environment >/dev/null 2>&1; then
    return 0
  fi

  if [ "${XDG_SESSION_TYPE:-}" = "x11" ]; then
    dbus-update-activation-environment --systemd --unset WAYLAND_DISPLAY 2>/dev/null || true
  fi

  dbus-update-activation-environment --systemd \
    XDG_SESSION_TYPE GDK_BACKEND QT_QPA_PLATFORM QT_QPA_PLATFORMTHEME XDG_CURRENT_DESKTOP \
    2>/dev/null || true
}

_kill_procs() {
  local name
  for name in "$@"; do
    killall -q "$name" 2>/dev/null || true
  done
  sleep 0.2
  for name in "$@"; do
    killall -9 -q "$name" 2>/dev/null || true
  done
}

_kill_procs_pattern() {
  local pattern="$1"
  pkill -f "$pattern" 2>/dev/null || true
  sleep 0.2
  pkill -9 -f "$pattern" 2>/dev/null || true
}

stop_cava_instance() {
  if pgrep -x cava >/dev/null 2>&1; then
    killall cava 2>/dev/null || true
    echo "Cava: instancia terminada (cambio de sesión)"
  fi
}

# Al entrar en i3/X11: termina restos Wayland/Hyprland (y bandeja duplicada).
stop_wayland_session_processes() {
  echo "session-env: terminando procesos Wayland/Hyprland…"
  stop_cava_instance
  _kill_procs_pattern '/wb_autohide'
  _kill_procs \
    Hyprland hyprland waybar wb_autohide ignis hypridle swaync hyprsunset \
    xdg-desktop-portal-hyprland awww-daemon mako
  _kill_procs nm-applet blueman-applet copyq xdg-desktop-portal
  _kill_procs_pattern 'polkit-kde-authentication-agent'
}

# Al entrar en Hyprland: termina restos X11/i3 (y bandeja duplicada).
stop_x11_session_processes() {
  echo "session-env: terminando procesos X11/i3…"
  stop_cava_instance
  _kill_procs \
    dunst mako polybar flameshot picom compton xwinwrap mpvpaper \
    xdg-desktop-portal-gtk bumblebee-status
  _kill_procs_pattern 'bumblebee-status'
  _kill_procs_pattern 'i3bgwin'
  _kill_procs nm-applet blueman-applet copyq xdg-desktop-portal
  _kill_procs_pattern 'polkit-kde-authentication-agent'
}

_start_polkit_agent() {
  local agent
  if pgrep -f 'polkit.*authentication-agent' >/dev/null 2>&1; then
    return 0
  fi
  for agent in \
    /usr/lib/polkit-kde-authentication-agent-1 \
    /usr/libexec/polkit-kde-authentication-agent-1 \
    /usr/lib/polkit-gnome/polkit-gnome-authentication-agent-1; do
    if [ -x "$agent" ]; then
      "$agent" &
      return 0
    fi
  done
}

_session_exports() {
  # shellcheck disable=SC1091
  [ -f "${HOME}/.config/bash/env.active.sh" ] && source "${HOME}/.config/bash/env.active.sh"
}

_tray_applet_running() {
  local id="$1"
  case "$id" in
    nm-applet) pgrep -x nm-applet >/dev/null 2>&1 ;;
    blueman-applet) pgrep -f '[b]lueman-applet' >/dev/null 2>&1 ;;
    copyq) pgrep -x copyq >/dev/null 2>&1 ;;
    *) return 1 ;;
  esac
}

_wait_for_tray_host() {
  local mode="$1" i=0 max=40
  while [ "$i" -lt "$max" ]; do
    case "$mode" in
      wayland)
        pgrep -x waybar >/dev/null 2>&1 && return 0
        ;;
      x11)
        pgrep -x i3bar >/dev/null 2>&1 && return 0
        ;;
    esac
    sleep 0.25
    i=$((i + 1))
  done
  echo "session-env: bandeja ($mode): host no listo; lanzando applets igual." >&2
  return 0
}

_launch_tray_applet() {
  local id="$1"
  shift
  if _tray_applet_running "$id"; then
    return 0
  fi
  echo "session-env: iniciando $id…"
  "$@" &
  sleep 0.4
}

# nm-applet / blueman / copyq — tras waybar o i3bar (bandeja disponible).
ensure_tray_applets() {
  local mode="${1:-}"
  if [ -z "$mode" ] && [ -f "$SESSION_MODE_FILE" ]; then
    mode="$(tr -d '[:space:]' <"$SESSION_MODE_FILE")"
  fi
  mode="${mode:-hyprland}"
  _session_exports
  case "$mode" in
    x11 | i3)
      if [ -z "${DISPLAY:-}" ]; then
        echo "session-env: sin DISPLAY; applets de bandeja omitidos." >&2
        return 0
      fi
      _wait_for_tray_host x11
      command -v nm-applet >/dev/null 2>&1 &&
        _launch_tray_applet nm-applet env GDK_BACKEND=x11 QT_QPA_PLATFORM=xcb nm-applet --indicator
      command -v blueman-applet >/dev/null 2>&1 &&
        _launch_tray_applet blueman-applet env GDK_BACKEND=x11 QT_QPA_PLATFORM=xcb blueman-applet
      command -v copyq >/dev/null 2>&1 &&
        _launch_tray_applet copyq env GDK_BACKEND=x11 QT_QPA_PLATFORM=xcb copyq
      ;;
    *)
      _wait_for_tray_host wayland
      command -v nm-applet >/dev/null 2>&1 &&
        _launch_tray_applet nm-applet env GDK_BACKEND=wayland QT_QPA_PLATFORM=wayland nm-applet --indicator
      command -v blueman-applet >/dev/null 2>&1 &&
        _launch_tray_applet blueman-applet env GDK_BACKEND=wayland QT_QPA_PLATFORM=wayland blueman-applet
      command -v copyq >/dev/null 2>&1 &&
        _launch_tray_applet copyq env GDK_BACKEND=wayland QT_QPA_PLATFORM=wayland copyq
      ;;
  esac
}

# Tras limpiar la sesión opuesta: portales y notificaciones (no bandeja; ver ensure_tray_applets).
start_x11_session_services() {
  echo "session-env: arrancando servicios X11/i3…"
  if [ -z "${DISPLAY:-}" ]; then
    echo "session-env: sin DISPLAY; omitido (espera arranque de i3)." >&2
    return 0
  fi
  command -v dunst >/dev/null 2>&1 && ! pgrep -x dunst >/dev/null 2>&1 && dunst &
  if [ -x /usr/lib/xdg-desktop-portal ] && ! pgrep -x xdg-desktop-portal >/dev/null 2>&1; then
    /usr/lib/xdg-desktop-portal &
  fi
  if [ -x /usr/lib/xdg-desktop-portal-gtk ] && ! pgrep -x xdg-desktop-portal-gtk >/dev/null 2>&1; then
    /usr/lib/xdg-desktop-portal-gtk &
  fi
  _start_polkit_agent
}

# Tras limpiar restos X11: portales Wayland y swaync (bandeja → ensure_tray_applets).
start_wayland_session_services() {
  echo "session-env: arrancando servicios Hyprland…"
  killall -e xdg-desktop-portal-hyprland 2>/dev/null || true
  killall xdg-desktop-portal 2>/dev/null || true
  sleep 0.5
  if [ -x /usr/lib/xdg-desktop-portal-hyprland ]; then
    /usr/lib/xdg-desktop-portal-hyprland &
    sleep 1
  fi
  if [ -x /usr/lib/xdg-desktop-portal ] && ! pgrep -x xdg-desktop-portal >/dev/null 2>&1; then
    /usr/lib/xdg-desktop-portal &
  fi
  _start_polkit_agent
  command -v swaync >/dev/null 2>&1 && ! pgrep -x swaync >/dev/null 2>&1 && swaync &
}

activate_cava_x11_profile() {
  local theme_id="${1:-}"
  local palettes cava_slug src dst

  if [ -z "$theme_id" ] && [ -f "${HOME}/.cache/ignis/active-theme.json" ]; then
    theme_id="$(python3 -c "import json; print(json.load(open('${HOME}/.cache/ignis/active-theme.json')).get('active',''))" 2>/dev/null || true)"
  fi
  theme_id="${theme_id:-blue}"

  # shellcheck source=lib/cava-theme.sh
  source "$(dirname "${BASH_SOURCE[0]}")/cava-theme.sh"

  palettes="$(find_palettes_file)" || {
    echo "cava-x11: palettes.json no encontrado; usando config.txt" >&2
    src="${CONFIG_ROOT:-$HOME/hyprland}/cava/x11/config.txt"
    dst="${HOME}/.config/cava/config"
    if [ -f "$src" ]; then
      mkdir -p "$(dirname "$dst")"
      cp "$src" "$dst"
      echo "Cava X11: config.txt → config"
    fi
    return 0
  }

  cava_slug="$(python3 - "$theme_id" "$palettes" <<'PY'
import json, sys
from pathlib import Path
theme_id = sys.argv[1]
data = json.loads(Path(sys.argv[2]).read_text())
theme = data.get("themes", {}).get(theme_id, {})
print(theme.get("cava", theme_id.replace("_", "-")))
PY
)"

  local root="${CONFIG_ROOT:-$HOME/hyprland}"
  for src in \
    "${HOME}/.config/cava/x11/config.${cava_slug}" \
    "$root/cava/x11/config.${cava_slug}" \
    "${HOME}/.config/cava/x11/config.txt" \
    "$root/cava/x11/config.txt"; do
    if [ -f "$src" ]; then
      dst="${HOME}/.config/cava/config"
      mkdir -p "$(dirname "$dst")"
      cp "$src" "$dst"
      echo "Cava X11: $(basename "$src") → config"
      if pgrep -x cava >/dev/null 2>&1; then
        killall cava 2>/dev/null || true
        echo "Cava: instancia terminada (relanzar manualmente en X11)"
      fi
      return 0
    fi
  done
  echo "cava-x11: no hay config X11; omitido." >&2
  return 1
}
