#!/usr/bin/env bash
# Reinicio ordenado: waybar → hypr reload → ignis (último). swaync solo en deploy --all.

RELOAD_STEP_DELAY="${RELOAD_STEP_DELAY:-2}"

reload_step_sleep() {
  sleep "${RELOAD_STEP_DELAY}"
}

kill_service_once() {
  local name="$1"
  killall "$name" 2>/dev/null || true
  sleep 0.3
  if pgrep -x "$name" >/dev/null 2>&1; then
    killall -9 "$name" 2>/dev/null || true
    sleep 0.2
  fi
}

ensure_service_running() {
  local name="$1"
  shift
  local -a start_cmd=("$@")

  if pgrep -x "$name" >/dev/null 2>&1; then
    return 0
  fi

  if [ ${#start_cmd[@]} -gt 0 ] && command -v "${start_cmd[0]}" >/dev/null 2>&1; then
    "${start_cmd[@]}" &
    echo "Iniciado: $name (no estaba activo tras reload)"
  fi
}

restart_service() {
  local name="$1"
  shift
  kill_service_once "$name"
  ensure_service_running "$name" "$@"
}

reload_hyprland_config() {
  if ! command -v hyprctl >/dev/null 2>&1; then
    return 0
  fi
  echo "Recargando Hyprland..."
  hyprctl reload 2>/dev/null || echo "Aviso: hyprctl reload falló (¿Hyprland no activo?)"
  hyprctl configerrors 2>/dev/null || true
}

_SERVICE_RELOAD_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib/ignis-theme.sh
source "$_SERVICE_RELOAD_DIR/ignis-theme.sh"
# shellcheck source=lib/powerline-theme.sh
source "$_SERVICE_RELOAD_DIR/powerline-theme.sh"

# apply-theme / deploy normal: waybar → hypr → ignis. Sin swaync.
apply_theme_reload_flow() {
  restart_service waybar waybar
  reload_hyprland_config
  reload_step_sleep
  ensure_service_running waybar waybar
  apply_ignis_theme
  reload_eww_if_running
  echo "Wofi actualizado (~/.config/wofi/colors, style.css)"
}

# deploy --all: reinicia swaync al final (ignis ya aplicado por apply-theme).
deploy_all_post_flow() {
  restart_service swaync swaync
  echo "Swaync: reiniciado (deploy --all)"

  # Esperar a que el daemon de notificaciones responda (evita colgar notify-send).
  local i=0
  while [ "$i" -lt 24 ]; do
    if dbus-send --session --print-reply \
      --dest=org.freedesktop.Notifications \
      /org/freedesktop/Notifications \
      org.freedesktop.Notifications.GetCapabilities >/dev/null 2>&1; then
      break
    fi
    sleep 0.25
    i=$((i + 1))
  done
}

# Fallback deploy si apply-theme falla.
deploy_reload_flow() {
  apply_theme_reload_flow
  restart_powerline_daemon
  # shellcheck source=lib/nvim-theme.sh
  source "$_SERVICE_RELOAD_DIR/nvim-theme.sh"
  if [ -f "$HOME/.cache/ignis/active-theme.json" ]; then
    local tid
    tid="$(python3 -c "import json; print(json.load(open('$HOME/.cache/ignis/active-theme.json')).get('active','blue'))" 2>/dev/null || echo blue)"
    activate_nvim_profile "$tid" || true
  fi
  ensure_service_running hypridle hypridle
}

# Super+Shift+R: mismo orden; sin swaync.
hypr_refresh_flow() {
  restart_service waybar waybar
  reload_hyprland_config
  reload_step_sleep
  ensure_service_running waybar waybar
  apply_ignis_theme
  reload_eww_if_running
  ensure_service_running hypridle hypridle
}

reset_waybar_position_top() {
  local waybar_config="${1:-$HOME/.config/waybar/config}"
  local state_file="$HOME/.cache/hypr/waybar-position.json"
  local user_options="$HOME/.config/ignis/user_options.json"

  mkdir -p "$(dirname "$state_file")"
  printf '%s\n' '{"position": "top"}' > "$state_file"

  if [ -f "$waybar_config" ]; then
    sed -i 's/"position"[[:space:]]*:[[:space:]]*"\(top\|bottom\)"/"position": "top"/' "$waybar_config"
  fi

  if [ -f "$user_options" ]; then
    python3 - <<'PY' "$user_options"
import json
import sys
from pathlib import Path

path = Path(sys.argv[1])
try:
    opts = json.loads(path.read_text())
except (json.JSONDecodeError, OSError):
    opts = {}
opts.setdefault("bar", {})["position"] = "top"
opts.setdefault("bar", {}).setdefault("height", 26)
path.write_text(json.dumps(opts, indent=2) + "\n")
PY
  fi
  echo "Waybar: posición por defecto → top"
}

reload_eww_if_running() {
  if ! command -v eww >/dev/null 2>&1; then
    return 0
  fi
  if ! pgrep -x eww >/dev/null 2>&1; then
    return 0
  fi
  echo "Recargando Eww..."
  eww reload 2>/dev/null || true
}

send_theme_notification() {
  local cache="$HOME/.cache/ignis/active-theme.json"
  if [ ! -f "$cache" ] || ! command -v notify-send >/dev/null 2>&1; then
    return 0
  fi

  python3 - <<'PY' || true
import json
import subprocess
from pathlib import Path

cache = Path.home() / ".cache" / "ignis" / "active-theme.json"
try:
    data = json.loads(cache.read_text())
except (json.JSONDecodeError, OSError):
    raise SystemExit(0)

label = data.get("label", data.get("active", "Tema"))
next_label = data.get("next_label", "")
next_id = data.get("next_id", "")
body = f"Siguiente: {next_label}" if next_label else f"Siguiente: {next_id}"

args = [
    "notify-send",
    "-t",
    "2500",
    "-i",
    "preferences-desktop-theme-symbolic",
    f"Tema activo: {label}",
    body,
]

try:
    subprocess.Popen(
        args,
        stdout=subprocess.DEVNULL,
        stderr=subprocess.DEVNULL,
        start_new_session=True,
    )
except OSError:
    pass
PY
}
