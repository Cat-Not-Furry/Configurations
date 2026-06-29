#!/usr/bin/env bash
# Variables de entorno para applets de bandeja (blueman-manager al clic izquierdo).
# Lee ~/.config/cnf-bin/config.toml → [session.x11] / [session.wayland]

resolve_cnf_config() {
  if [[ -n "${CNF_BIN_CONFIG:-}" && -f "$CNF_BIN_CONFIG" ]]; then
    printf '%s\n' "$CNF_BIN_CONFIG"
    return 0
  fi
  if [[ -f "${HOME}/.config/cnf-bin/config.toml" ]]; then
    printf '%s\n' "${HOME}/.config/cnf-bin/config.toml"
    return 0
  fi
  local candidate
  for candidate in \
    "${CNF_BIN_ROOT:-}/config.toml" \
    "${HOME}/Games/configurations/shared/cnf-bin/config.toml"; do
    if [[ -f "$candidate" ]]; then
      printf '%s\n' "$candidate"
      return 0
    fi
  done
  return 1
}

# read_session_tray_key FILE SECTION KEY
read_session_tray_key() {
  local file="$1" section="$2" key="$3"
  awk -v section="$section" -v key="$key" '
    $0 ~ ("^\\[" section "\\]") { in_sec = 1; next }
    /^\[/ { in_sec = 0 }
    in_sec && $1 == key {
      gsub(/^[^=]*=[[:space:]]*"/, "")
      gsub(/".*$/, "")
      gsub(/^[[:space:]]+|[[:space:]]+$/, "")
      print
      exit
    }
  ' "$file"
}

# session_tray_mode: x11 | i3 → session.x11 ; wayland/hyprland → session.wayland
session_tray_section() {
  case "${1:-}" in
    x11 | i3) printf '%s\n' "session.x11" ;;
    *) printf '%s\n' "session.wayland" ;;
  esac
}

# Exporta variables para blueman-applet / blueman-manager (heredadas al clic).
export_blueman_tray_env() {
  local mode="${1:-x11}"
  local section config gdk qt manager dbus_display

  section="$(session_tray_section "$mode")"
  gdk="x11"
  qt="xcb"
  manager="blueman-manager"

  if config="$(resolve_cnf_config)"; then
    gdk="$(read_session_tray_key "$config" "$section" blueman_gdk_backend)"
    qt="$(read_session_tray_key "$config" "$section" blueman_qt_platform)"
    manager="$(read_session_tray_key "$config" "$section" blueman_manager)"
    dbus_display="$(read_session_tray_key "$config" "$section" blueman_dbus_display)"
  fi

  gdk="${gdk:-x11}"
  qt="${qt:-xcb}"
  manager="${manager:-blueman-manager}"
  dbus_display="${dbus_display:-1}"

  export GDK_BACKEND="$gdk"
  export QT_QPA_PLATFORM="$qt"
  export QT_QPA_PLATFORMTHEME="${QT_QPA_PLATFORMTHEME:-qt5ct}"
  export BLUEMAN_USE_NOTIFICATIONS="${BLUEMAN_USE_NOTIFICATIONS:-0}"
  export BLUEMAN_MANAGER="$manager"

  if [[ "$dbus_display" == "1" && -n "${DISPLAY:-}" ]]; then
    export DBUS_SESSION_BUS_ADDRESS="${DBUS_SESSION_BUS_ADDRESS:-unix:path=/run/user/$(id -u)/bus}"
  fi

  if [[ -n "${DISPLAY:-}" ]]; then
    export DISPLAY
    export XAUTHORITY="${XAUTHORITY:-$HOME/.Xauthority}"
  fi
}

# argv para env al lanzar blueman-applet (array plano vía nombre).
blueman_applet_env_args() {
  export_blueman_tray_env "${1:-x11}"
  printf '%s\0' \
    "GDK_BACKEND=$GDK_BACKEND" \
    "QT_QPA_PLATFORM=$QT_QPA_PLATFORM" \
    "QT_QPA_PLATFORMTHEME=$QT_QPA_PLATFORMTHEME" \
    "BLUEMAN_USE_NOTIFICATIONS=$BLUEMAN_USE_NOTIFICATIONS" \
    "BLUEMAN_MANAGER=$BLUEMAN_MANAGER" \
    ${DISPLAY:+DISPLAY=$DISPLAY} \
    ${XAUTHORITY:+XAUTHORITY=$XAUTHORITY} \
    ${DBUS_SESSION_BUS_ADDRESS:+DBUS_SESSION_BUS_ADDRESS=$DBUS_SESSION_BUS_ADDRESS}
}
