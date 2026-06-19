#!/usr/bin/env bash
# Reinicios sin duplicar: kill una vez → reload → ensure solo si falta instancia.

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

reload_hyprland_config() {
  if ! command -v hyprctl >/dev/null 2>&1; then
    return 0
  fi
  echo "Recargando Hyprland..."
  hyprctl reload 2>/dev/null || echo "Aviso: hyprctl reload falló (¿Hyprland no activo?)"
  hyprctl configerrors 2>/dev/null || true
}

# Tras apply-theme: reload (exec.conf mata servicios) → ensure.
apply_theme_reload_flow() {
  reload_hyprland_config
  reload_step_sleep
  ensure_service_running ignis ignis init
  ensure_service_running waybar waybar
  echo "Wofi actualizado (~/.config/wofi/colors, style.css)"
}

# Tras deploy: reload → ensure todos (sin kill previo; exec.conf mata en reload).
deploy_reload_flow() {
  reload_hyprland_config
  reload_step_sleep
  ensure_service_running ignis ignis init
  ensure_service_running waybar waybar
  ensure_service_running hypridle hypridle
  ensure_service_running swaync swaync
}

# Reload manual seguro (keybind): reload + ensure sin kill previo duplicado.
hypr_refresh_flow() {
  reload_hyprland_config
  reload_step_sleep
  ensure_service_running ignis ignis init
  ensure_service_running waybar waybar
  ensure_service_running hypridle hypridle
  ensure_service_running swaync swaync
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
