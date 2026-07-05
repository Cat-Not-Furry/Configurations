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
  _write_session_env_file wayland Hyprland
}

write_x11_env() {
  _write_session_env_file x11 i3
}

# Paridad Hyprland monitors.conf (env = GDK_BACKEND / QT_QPA_PLATFORM) + config.toml [session.*]
_write_session_env_file() {
  local mode="$1"
  local desktop="$2"
  local dest="${HOME}/.config/bash/env.active.sh"
  local session_type gdk qt theme dbus_line unset_line=""
  local uid

  case "$mode" in
    wayland | hyprland)
      session_type="wayland"
      gdk="wayland"
      qt="wayland"
      ;;
    *)
      session_type="x11"
      gdk="x11"
      qt="xcb"
      unset_line="unset WAYLAND_DISPLAY 2>/dev/null || true"
      ;;
  esac
  theme="qt5ct"

  if _load_session_tray_lib 2>/dev/null; then
    export_blueman_tray_env "$mode"
    gdk="${GDK_BACKEND:-$gdk}"
    qt="${QT_QPA_PLATFORM:-$qt}"
    theme="${QT_QPA_PLATFORMTHEME:-$theme}"
  fi

  uid="$(id -u)"
  dbus_line="export DBUS_SESSION_BUS_ADDRESS=\"\${DBUS_SESSION_BUS_ADDRESS:-unix:path=/run/user/${uid}/bus}\""
  display_line="export DISPLAY=\"\${DISPLAY:-:0}\""
  xauth_line="export XAUTHORITY=\"\${XAUTHORITY:-\$HOME/.Xauthority}\""

  mkdir -p "$(dirname "$dest")"
  cat >"$dest" <<EOF
# Generado por session-env.sh — no editar a mano
# Blueman: paridad con hyprland/conf.d/monitors.conf + cnf-bin/config.toml [session.${mode}]
export XDG_SESSION_TYPE=${session_type}
export GDK_BACKEND=${gdk}
export QT_QPA_PLATFORM=${qt}
export QT_QPA_PLATFORMTHEME=${theme}
export XDG_CURRENT_DESKTOP=${desktop}
export BLUEMAN_USE_NOTIFICATIONS=\${BLUEMAN_USE_NOTIFICATIONS:-0}
export BLUEMAN_MANAGER=\${BLUEMAN_MANAGER:-blueman-manager}
${display_line}
${xauth_line}
${dbus_line}
${unset_line}
EOF
  echo "Entorno: perfil ${desktop} → $dest"
}

# blueman-manager se activa vía D-Bus (org.blueman.Manager); requiere DISPLAY/GDK en el entorno
# de activación systemd, no solo en el proceso blueman-applet.
ensure_dbus_graphical_activation() {
  local mode="${1:-x11}"
  local uid

  uid="$(id -u)"
  export DISPLAY="${DISPLAY:-:0}"
  export XAUTHORITY="${XAUTHORITY:-$HOME/.Xauthority}"
  export DBUS_SESSION_BUS_ADDRESS="${DBUS_SESSION_BUS_ADDRESS:-unix:path=/run/user/${uid}/bus}"

  if _load_session_tray_lib 2>/dev/null; then
    export_blueman_tray_env "$mode"
  else
    case "$mode" in
      x11 | i3)
        export GDK_BACKEND=x11
        export QT_QPA_PLATFORM=xcb
        ;;
      *)
        export GDK_BACKEND=wayland
        export QT_QPA_PLATFORM=wayland
        ;;
    esac
    export QT_QPA_PLATFORMTHEME="${QT_QPA_PLATFORMTHEME:-qt5ct}"
  fi

  if ! command -v dbus-update-activation-environment >/dev/null 2>&1; then
    echo "session-env: dbus-update-activation-environment no disponible." >&2
    return 0
  fi

  if [ "${XDG_SESSION_TYPE:-$mode}" = "x11" ] || [ "$mode" = "x11" ] || [ "$mode" = "i3" ]; then
    dbus-update-activation-environment --systemd --unset WAYLAND_DISPLAY 2>/dev/null || true
  fi

  dbus-update-activation-environment --systemd \
    DISPLAY XAUTHORITY DBUS_SESSION_BUS_ADDRESS \
    XDG_SESSION_TYPE GDK_BACKEND QT_QPA_PLATFORM QT_QPA_PLATFORMTHEME XDG_CURRENT_DESKTOP \
    BLUEMAN_USE_NOTIFICATIONS BLUEMAN_MANAGER \
    2>/dev/null || true
}

propagate_env_from_file() {
  local mode="x11"
  if [ -f "$SESSION_MODE_FILE" ]; then
    mode="$(tr -d '[:space:]' <"$SESSION_MODE_FILE")"
  fi
  case "$mode" in
    hyprland | wayland) mode="wayland" ;;
    *) mode="x11" ;;
  esac
  ensure_dbus_graphical_activation "$mode"
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

# Restos Hyprland/Wayland sin tocar bandeja ni portales (p. ej. deploy --config-i3).
stop_hyprland_orphans() {
  echo "session-env: terminando restos Hyprland (sin bandeja)…"
  stop_cava_instance
  _kill_procs_pattern '/wb_autohide'
  _kill_procs \
    Hyprland hyprland waybar wb_autohide ignis hypridle swaync hyprsunset \
    xdg-desktop-portal-hyprland awww-daemon mako
}

# Restos polybar X11 (bumblebee/i3bar no se tocan en reload de deploy).
stop_x11_polybar() {
  pgrep -x polybar >/dev/null 2>&1 || return 0
  killall -q polybar 2>/dev/null || true
  sleep 0.2
  pgrep -x polybar >/dev/null 2>&1 && killall -9 -q polybar 2>/dev/null || true
}

# Alias legacy — solo polybar.
stop_x11_bar_orphans() {
  stop_x11_polybar
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

_load_session_tray_lib() {
  local lib
  for lib in \
    "${HOME}/.config/cnf-bin/lib/session-tray.sh" \
    "${CONFIG_ROOT:-$HOME/Games/configurations}/shared/cnf-bin/lib/session-tray.sh" \
    "${HOME}/Games/configurations/shared/cnf-bin/lib/session-tray.sh"; do
    if [ -f "$lib" ]; then
      # shellcheck source=lib/session-tray.sh
      source "$lib"
      return 0
    fi
  done
  return 1
}

_launch_blueman_applet() {
  local mode="$1"
  if _load_session_tray_lib; then
    export_blueman_tray_env "$mode"
    _launch_tray_applet blueman-applet env \
      GDK_BACKEND="$GDK_BACKEND" \
      QT_QPA_PLATFORM="$QT_QPA_PLATFORM" \
      QT_QPA_PLATFORMTHEME="${QT_QPA_PLATFORMTHEME:-qt5ct}" \
      BLUEMAN_USE_NOTIFICATIONS="${BLUEMAN_USE_NOTIFICATIONS:-0}" \
      BLUEMAN_MANAGER="${BLUEMAN_MANAGER:-blueman-manager}" \
      ${DISPLAY:+DISPLAY="$DISPLAY"} \
      ${XAUTHORITY:+XAUTHORITY="$XAUTHORITY"} \
      ${DBUS_SESSION_BUS_ADDRESS:+DBUS_SESSION_BUS_ADDRESS="$DBUS_SESSION_BUS_ADDRESS"} \
      blueman-applet
  else
    case "$mode" in
      x11 | i3)
        _launch_tray_applet blueman-applet env GDK_BACKEND=x11 QT_QPA_PLATFORM=xcb blueman-applet
        ;;
      *)
        _launch_tray_applet blueman-applet env GDK_BACKEND=wayland QT_QPA_PLATFORM=wayland blueman-applet
        ;;
    esac
  fi
}

# nm-applet / blueman / copyq — tras waybar o i3bar (bandeja disponible).
ensure_tray_applets() {
  local mode="${1:-}"
  if [ -z "$mode" ] && [ -f "$SESSION_MODE_FILE" ]; then
    mode="$(tr -d '[:space:]' <"$SESSION_MODE_FILE")"
  fi
  mode="${mode:-hyprland}"
  _session_exports
  ensure_dbus_graphical_activation "$mode"
  case "$mode" in
    x11 | i3)
      if [ -z "${DISPLAY:-}" ]; then
        echo "session-env: sin DISPLAY; applets de bandeja omitidos." >&2
        return 0
      fi
      _wait_for_tray_host x11
      command -v nm-applet >/dev/null 2>&1 &&
        _launch_tray_applet nm-applet env GDK_BACKEND=x11 QT_QPA_PLATFORM=xcb nm-applet --indicator
      command -v blueman-applet >/dev/null 2>&1 && _launch_blueman_applet x11
      command -v copyq >/dev/null 2>&1 &&
        _launch_tray_applet copyq env GDK_BACKEND=x11 QT_QPA_PLATFORM=xcb copyq
      ;;
    *)
      _wait_for_tray_host wayland
      command -v nm-applet >/dev/null 2>&1 &&
        _launch_tray_applet nm-applet env GDK_BACKEND=wayland QT_QPA_PLATFORM=wayland nm-applet --indicator
      command -v blueman-applet >/dev/null 2>&1 && _launch_blueman_applet wayland
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

_load_i3_theme_lib() {
  local candidate root
  root="${CONFIG_ROOT:-$HOME/Games/configurations}"
  for candidate in \
    "${I3_WM_ROOT:-$root/I3/i3-wm}/scripts/i3-theme-lib.sh" \
    "$root/I3/i3-wm/scripts/i3-theme-lib.sh" \
    "$root/i3-wm/scripts/i3-theme-lib.sh" \
    "${HOME}/.config/i3/scripts/i3-theme-lib.sh"; do
    if [ -f "$candidate" ]; then
      # shellcheck source=/dev/null
      source "$candidate"
      return 0
    fi
  done
  return 1
}

_resolve_i3_theme_for_x11() {
  local i3_theme_arg="${1:-}"
  if _load_i3_theme_lib 2>/dev/null && declare -f resolve_i3_theme >/dev/null; then
    resolve_i3_theme "" "$i3_theme_arg"
    return 0
  fi
  case "$i3_theme_arg" in
    classic | iceberg) printf '%s\n' "$i3_theme_arg" ;;
    *) printf '%s\n' classic ;;
  esac
}

_resolve_palette_for_x11() {
  local i3_theme_arg="${1:-}"
  local i3_theme
  i3_theme="$(_resolve_i3_theme_for_x11 "$i3_theme_arg")"
  if _load_i3_theme_lib 2>/dev/null && declare -f nvim_palette_for_i3 >/dev/null; then
    nvim_palette_for_i3 "$i3_theme"
    return 0
  fi
  case "$i3_theme" in
    iceberg) printf '%s\n' blue ;;
    *) printf '%s\n' classic ;;
  esac
}

_resolve_tmux_x11_colors_slug() {
  local i3_theme_arg="${1:-}"
  local i3_theme
  i3_theme="$(_resolve_i3_theme_for_x11 "$i3_theme_arg")"
  if _load_i3_theme_lib 2>/dev/null && declare -f tmux_colors_slug_for_i3 >/dev/null; then
    tmux_colors_slug_for_i3 "$i3_theme"
    return 0
  fi
  case "$i3_theme" in
    iceberg) printf '%s\n' gray ;;
    *) printf '%s\n' classic ;;
  esac
}

_cava_shared_root() {
  if [ -n "${SHARED_ROOT:-}" ] && [ -d "${SHARED_ROOT}/cava" ]; then
    printf '%s\n' "$SHARED_ROOT/cava"
  elif [ -d "${CONFIG_ROOT:-}/shared/cava" ]; then
    printf '%s\n' "${CONFIG_ROOT}/shared/cava"
  else
    printf '%s\n' "${CONFIG_ROOT:-$HOME/Games/configurations}/cava"
  fi
}

_find_cava_x11_config() {
  local cava_slug="$1"
  local shared_root candidate
  shared_root="$(_cava_shared_root)"
  for candidate in \
    "${HOME}/.config/cava/x11/config.${cava_slug}" \
    "${HOME}/.config/cava/wayland/config.${cava_slug}" \
    "${HOME}/.config/cava/wayland/${cava_slug}.conf" \
    "$shared_root/x11/config.${cava_slug}" \
    "$shared_root/wayland/config.${cava_slug}" \
    "$shared_root/wayland/${cava_slug}.conf" \
    "${HOME}/.config/cava/x11/config.txt" \
    "$shared_root/x11/config.txt"; do
    if [ -f "$candidate" ]; then
      printf '%s\n' "$candidate"
      return 0
    fi
  done
  return 1
}

activate_tmux_x11_profile() {
  local i3_theme_arg="${1:-}"
  local colors_slug colors_src active_dst tmux_conf shared_root

  colors_slug="$(_resolve_tmux_x11_colors_slug "$i3_theme_arg")"
  shared_root="${SHARED_ROOT:-${CONFIG_ROOT:-$HOME/Games/configurations}/shared}"

  for colors_src in \
    "${HOME}/.config/tmux/colors/${colors_slug}.conf" \
    "$shared_root/tmux/colors/${colors_slug}.conf" \
    "${CONFIG_ROOT:-}/tmux/colors/${colors_slug}.conf"; do
    if [ -f "$colors_src" ]; then
      break
    fi
  done

  active_dst="${HOME}/.config/tmux/colors.active.conf"
  tmux_conf="${HOME}/.config/tmux/tmux.conf"

  if [ ! -f "$colors_src" ]; then
    echo "tmux-x11: no existe colors/${colors_slug}.conf; omitido." >&2
    return 1
  fi

  mkdir -p "${HOME}/.config/tmux"
  cp "$colors_src" "$active_dst"
  echo "Tmux X11: colors/${colors_slug}.conf → colors.active.conf (i3=$(_resolve_i3_theme_for_x11 "$i3_theme_arg"))"

  if [ -f "$tmux_conf" ] && tmux info &>/dev/null; then
    tmux source-file "$tmux_conf" 2>/dev/null && echo "Tmux: config recargada en sesión activa" || true
  fi
  return 0
}

activate_tmux_gray_profile() {
  activate_tmux_x11_profile "$@"
}

activate_copyq_for_i3_theme() {
  local i3_theme_arg="${1:-}"
  local palette script_dir

  if ! command -v copyq >/dev/null 2>&1; then
    echo "copyq-i3: copyq no instalado; omitido."
    return 0
  fi

  palette="$(_resolve_palette_for_x11 "$i3_theme_arg")"
  script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
  # shellcheck source=copyq-theme.sh
  source "$script_dir/copyq-theme.sh"
  activate_copyq_profile "$palette" || return $?
  echo "copyq-i3: palette=${palette} (i3=$(_resolve_i3_theme_for_x11 "$i3_theme_arg"))"
  return 0
}

activate_x11_shared_themes() {
  local i3_theme_arg="${1:-}"
  activate_tmux_x11_profile "$i3_theme_arg" || true
  activate_cava_x11_profile "$i3_theme_arg" || true
  activate_copyq_for_i3_theme "$i3_theme_arg" || true
}

# i3 ventanas + i3bar: copia themes/{classic,iceberg}.conf → 07-gaps_borders.conf.
activate_i3_theme_profile() {
  local script root reload_args=()

  root="${CONFIG_ROOT:-$HOME/Games/configurations}"
  if [[ -n "${DISPLAY:-}" ]] && command -v i3-msg >/dev/null 2>&1; then
    reload_args=()
  else
    reload_args=(--no-reload)
  fi

  for script in \
    "${HOME}/.config/i3/scripts/apply-i3-theme.sh" \
    "${I3_WM_ROOT:-$root/I3/i3-wm}/scripts/apply-i3-theme.sh" \
    "$root/I3/i3-wm/scripts/apply-i3-theme.sh" \
    "$root/i3-wm/scripts/apply-i3-theme.sh"; do
    if [[ -x "$script" ]]; then
      "$script" "${reload_args[@]}" || return $?
      echo "i3-theme: aplicado vía $(basename "$script")"
      return 0
    fi
  done
  echo "i3-theme: apply-i3-theme.sh no encontrado; omitido." >&2
  return 1
}

activate_cava_x11_profile() {
  local i3_theme_arg="${1:-}"
  local palette_id palettes cava_slug src dst

  case "$i3_theme_arg" in
    classic | iceberg) palette_id="$(_resolve_palette_for_x11 "$i3_theme_arg")" ;;
    "")
      palette_id="$(_resolve_palette_for_x11 "")" ;;
    *)
      palette_id="$i3_theme_arg" ;;
  esac

  # shellcheck source=lib/cava-theme.sh
  source "$(dirname "${BASH_SOURCE[0]}")/cava-theme.sh"

  palettes="$(find_palettes_file)" || {
    echo "cava-x11: palettes.json no encontrado; fallback por tema i3" >&2
    cava_slug="$palette_id"
    if ! src="$(_find_cava_x11_config "$cava_slug")"; then
      src="$(_find_cava_x11_config "classic")" || true
    fi
    if [ -n "${src:-}" ]; then
      dst="${HOME}/.config/cava/config"
      mkdir -p "$(dirname "$dst")"
      cp "$src" "$dst"
      echo "Cava X11: $(basename "$src") → config (i3=$(_resolve_i3_theme_for_x11 "$i3_theme_arg"))"
      if pgrep -x cava >/dev/null 2>&1; then
        killall cava 2>/dev/null || true
        echo "Cava: instancia terminada (relanzar manualmente en X11)"
      fi
      return 0
    fi
    return 1
  }

  cava_slug="$(python3 - "$palette_id" "$palettes" <<'PY'
import json, sys
from pathlib import Path
theme_id = sys.argv[1]
data = json.loads(Path(sys.argv[2]).read_text())
theme = data.get("themes", {}).get(theme_id, {})
print(theme.get("cava", theme_id.replace("_", "-")))
PY
)"

  if ! src="$(_find_cava_x11_config "$cava_slug")"; then
    echo "cava-x11: no hay config para slug=${cava_slug}; omitido." >&2
    return 1
  fi

  dst="${HOME}/.config/cava/config"
  mkdir -p "$(dirname "$dst")"
  cp "$src" "$dst"
  echo "Cava X11: $(basename "$src") → config (i3=$(_resolve_i3_theme_for_x11 "$i3_theme_arg"), palette=${palette_id})"
  if pgrep -x cava >/dev/null 2>&1; then
    killall cava 2>/dev/null || true
    echo "Cava: instancia terminada (relanzar manualmente en X11)"
  fi
  return 0
}
