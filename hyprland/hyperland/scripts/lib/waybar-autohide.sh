#!/usr/bin/env bash
# Autohide Waybar: Rust daemon (waybar/scripts/bin/wb_autohide; deploy → ~/.config/waybar/scripts/bin/).

WAYBAR_AUTOHIDE_STATE_FILE="${WAYBAR_AUTOHIDE_STATE_FILE:-$HOME/.cache/hypr/waybar-autohide.json}"
WAYBAR_POSITION_STATE_FILE="${WAYBAR_POSITION_STATE_FILE:-$HOME/.cache/hypr/waybar-position.json}"
WAYBAR_USER_CONFIG="${WAYBAR_USER_CONFIG:-$HOME/.config/waybar/config}"
WAYBAR_AUTOHIDE_DAEMON_NAME="wb_autohide"
WAYBAR_AUTOHIDE_PGREP_PATTERN='/wb_autohide --side'

waybar_autohide_bin() {
  local candidate config_root
  config_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../.." 2>/dev/null && pwd)"
  for candidate in \
    "$HOME/.config/waybar/scripts/bin/$WAYBAR_AUTOHIDE_DAEMON_NAME" \
    "/usr/local/bin/$WAYBAR_AUTOHIDE_DAEMON_NAME" \
    "${CONFIG_ROOT:-$config_root}/waybar/scripts/bin/$WAYBAR_AUTOHIDE_DAEMON_NAME"; do
    if [ -n "$candidate" ] && [ -x "$candidate" ]; then
      printf '%s\n' "$candidate"
      return 0
    fi
  done
  return 1
}

read_autohide_mode() {
  if [ ! -f "$WAYBAR_AUTOHIDE_STATE_FILE" ]; then
    printf 'normal\n'
    return 0
  fi
  python3 -c "
import json
from pathlib import Path
p = Path('$WAYBAR_AUTOHIDE_STATE_FILE')
try:
    mode = json.loads(p.read_text()).get('mode', 'normal')
except Exception:
    mode = 'normal'
print(mode if mode in ('normal', 'autohide') else 'normal')
" 2>/dev/null || printf 'normal\n'
}

write_autohide_mode() {
  local mode="$1"
  mkdir -p "$(dirname "$WAYBAR_AUTOHIDE_STATE_FILE")"
  python3 -c "
import json
from pathlib import Path
Path('$WAYBAR_AUTOHIDE_STATE_FILE').write_text(
    json.dumps({'mode': '$mode'}, indent=2) + '\n'
)
"
}

read_waybar_position() {
  if [ ! -f "$WAYBAR_POSITION_STATE_FILE" ]; then
    _read_waybar_position_from_config || printf 'top\n'
    return 0
  fi
  python3 -c "
import json
import re
from pathlib import Path

state = Path('$WAYBAR_POSITION_STATE_FILE')
config = Path('$WAYBAR_USER_CONFIG')
pos = 'top'
if state.is_file():
    try:
        pos = json.loads(state.read_text()).get('position', 'top')
    except Exception:
        pos = 'top'
if config.is_file():
    m = re.search(r'\"position\"\\s*:\\s*\"(top|bottom)\"', config.read_text())
    if m:
        cfg_pos = m.group(1)
        if pos != cfg_pos:
            pos = cfg_pos
print(pos if pos in ('top', 'bottom') else 'top')
" 2>/dev/null || _read_waybar_position_from_config || printf 'top\n'
}

_read_waybar_position_from_config() {
  [ -f "$WAYBAR_USER_CONFIG" ] || return 1
  python3 -c "
import re
from pathlib import Path
m = re.search(r'\"position\"\\s*:\\s*\"(top|bottom)\"', Path('$WAYBAR_USER_CONFIG').read_text())
print(m.group(1) if m else 'top')
" 2>/dev/null
}

_patch_waybar_config_file() {
  local config_path="$1"
  local mode="$2"
  [ -f "$config_path" ] || return 0

  local exclusive="true"
  if [ "$mode" = "autohide" ]; then
    exclusive="false"
  fi

  WAYBAR_PATCH_MODE="$mode" \
  WAYBAR_PATCH_EXCLUSIVE="$exclusive" \
  python3 - <<'PY' "$config_path"
import json
import re
import sys
from pathlib import Path

path = Path(sys.argv[1])
mode = __import__("os").environ["WAYBAR_PATCH_MODE"]
exclusive = __import__("os").environ["WAYBAR_PATCH_EXCLUSIVE"] == "true"
text = path.read_text()

def set_json_bool(key: str, value: bool) -> None:
    global text
    pat = rf'("{key}"\s*:\s*)(?:true|false)'
    repl = rf'\g<1>{"true" if value else "false"}'
    if re.search(pat, text):
        text = re.sub(pat, repl, text, count=1)
    else:
        text = text.replace(
            '"spacing":',
            f'"{key}": {"true" if value else "false"},\n  "spacing":',
            1,
        )

def set_json_str(key: str, value: str) -> None:
    global text
    pat = rf'("{key}"\s*:\s*)"(?:hide|show|toggle|reload|noop)"'
    repl = rf'\g<1>"{value}"'
    if re.search(pat, text):
        text = re.sub(pat, repl, text, count=1)
    else:
        text = text.replace(
            '"spacing":',
            f'"{key}": "{value}",\n  "spacing":',
            1,
        )

set_json_bool("exclusive", exclusive)
if mode == "autohide":
    set_json_str("on-sigusr1", "reload")
    set_json_str("on-sigusr2", "reload")
    set_json_bool("start_hidden", False)
else:
    set_json_bool("start_hidden", False)
    set_json_str("on-sigusr1", "hide")
    set_json_str("on-sigusr2", "show")
path.write_text(text)
PY
}

patch_waybar_autohide_config() {
  local mode="$1"
  _patch_waybar_config_file "$WAYBAR_USER_CONFIG" "$mode"
  if [ -n "${REPO_WAYBAR_CONFIG:-}" ] && [ -f "$REPO_WAYBAR_CONFIG" ]; then
    _patch_waybar_config_file "$REPO_WAYBAR_CONFIG" "$mode"
  elif [ -n "${CONFIG_ROOT:-}" ] && [ -f "$CONFIG_ROOT/waybar/config" ]; then
    _patch_waybar_config_file "$CONFIG_ROOT/waybar/config" "$mode"
  fi
}

stop_waybar_autohide_daemon() {
  pkill -f "$WAYBAR_AUTOHIDE_PGREP_PATTERN" 2>/dev/null || true
  killall wb_autohide 2>/dev/null || true
  sleep 0.2
  if pgrep -f "$WAYBAR_AUTOHIDE_PGREP_PATTERN" >/dev/null 2>&1; then
    pkill -9 -f "$WAYBAR_AUTOHIDE_PGREP_PATTERN" 2>/dev/null || true
  fi
}

start_waybar_autohide_daemon() {
  local side="${1:-top}"
  local bin
  bin="$(waybar_autohide_bin)" || return 1
  stop_waybar_autohide_daemon
  ensure_hyprland_daemon_env || true
  "$bin" --side "$side" &
  sleep 0.25
  sync_waybar_autohide_visibility
}

WAYBAR_AUTOHIDE_CSS="${WAYBAR_AUTOHIDE_CSS:-$HOME/.config/waybar/waybar-autohide-state.css}"

write_waybar_autohide_css() {
  local state="$1"
  local side="${2:-$(read_waybar_position)}"
  mkdir -p "$(dirname "$WAYBAR_AUTOHIDE_CSS")"
  if [ "$state" = "hidden" ]; then
    local edge_margin="  margin-top: -26px;
  margin-bottom: 0px;"
    if [ "$side" = "bottom" ]; then
      edge_margin="  margin-bottom: -26px;
  margin-top: 0px;"
    fi
    cat >"$WAYBAR_AUTOHIDE_CSS" <<EOF
window#waybar {
  opacity: 0;
  min-height: 0px;
  padding: 0px;
${edge_margin}
  border: none;
}
window#waybar > box {
  opacity: 0;
  min-height: 0px;
  padding: 0px;
  margin: 0px;
}
EOF
  else
    printf '%s\n' '/* autohide: visible */' >"$WAYBAR_AUTOHIDE_CSS"
  fi
}

reload_waybar_surface() {
  pkill -SIGUSR2 waybar 2>/dev/null || true
}

show_waybar() {
  write_waybar_autohide_css visible "$(read_waybar_position)"
  reload_waybar_surface
}

hide_waybar() {
  write_waybar_autohide_css hidden "$(read_waybar_position)"
  reload_waybar_surface
}

restart_waybar_for_autohide() {
  if declare -F kill_service_once >/dev/null 2>&1; then
    kill_service_once waybar
    _launch_waybar
  else
    killall waybar 2>/dev/null || true
    sleep 0.3
    _launch_waybar
  fi
  sleep 0.2
}

_strip_ansi() {
  printf '%s' "$1" | sed 's/\x1b\[[0-9;]*[a-zA-Z]//g'
}

_hypr_runtime_signature() {
  if [ -z "${XDG_RUNTIME_DIR:-}" ] || [ ! -d "$XDG_RUNTIME_DIR/hypr" ]; then
    return 1
  fi
  local sig
  sig="$(find "$XDG_RUNTIME_DIR/hypr" -mindepth 1 -maxdepth 1 -type d -printf '%f\n' 2>/dev/null | head -n 1)"
  if [ -z "$sig" ]; then
    sig="$(command ls --color=never -1 "$XDG_RUNTIME_DIR/hypr" 2>/dev/null | head -n 1)"
  fi
  sig="$(_strip_ansi "$sig")"
  [ -n "$sig" ] || return 1
  printf '%s' "$sig"
}

ensure_hyprland_daemon_env() {
  local sig
  sig="$(_hypr_runtime_signature)" || return 1
  export HYPRLAND_INSTANCE_SIGNATURE="$sig"
}

_launch_waybar() {
  ensure_hyprland_daemon_env || unset HYPRLAND_INSTANCE_SIGNATURE
  waybar &
}

hypr_workspace_has_windows() {
  command -v hyprctl >/dev/null 2>&1 || return 1
  ensure_hyprland_daemon_env || return 1
  local count
  count="$(hyprctl -j activeworkspace 2>/dev/null | python3 -c "
import json, sys
try:
    print(int(json.load(sys.stdin).get('windows', 0) or 0))
except Exception:
    print(0)
" 2>/dev/null || echo 0)"
  [ "${count:-0}" -gt 0 ]
}

# Escritorio vacío → visible; con ventanas → oculta (peek al borde vía wb_autohide).
sync_waybar_autohide_visibility() {
  if [ "$(read_autohide_mode)" != "autohide" ]; then
    return 0
  fi
  sleep 0.35
  if hypr_workspace_has_windows; then
    hide_waybar
  else
    show_waybar
  fi
}

restart_waybar_service() {
  # shellcheck disable=SC2128
  if declare -F kill_service_once >/dev/null 2>&1; then
    kill_service_once waybar
    ensure_service_running waybar waybar
    ensure_waybar_autohide_daemon
  else
    killall waybar 2>/dev/null || true
    sleep 0.3
    _launch_waybar
    sleep 0.2
    ensure_waybar_autohide_daemon
  fi
}

_daemon_running_side() {
  local cmd
  cmd="$(pgrep -af "$WAYBAR_AUTOHIDE_PGREP_PATTERN" 2>/dev/null | head -1 || true)"
  case "$cmd" in
    *"--side bottom"*) printf 'bottom\n' ;;
    *"--side top"*) printf 'top\n' ;;
    *) printf '\n' ;;
  esac
}

ensure_waybar_autohide_daemon() {
  if [ "$(read_autohide_mode)" != "autohide" ]; then
    if pgrep -f "$WAYBAR_AUTOHIDE_PGREP_PATTERN" >/dev/null 2>&1; then
      stop_waybar_autohide_daemon
      write_waybar_autohide_css visible
      reload_waybar_surface
    fi
    return 0
  fi
  local expected running
  expected="$(read_waybar_position)"
  running="$(_daemon_running_side)"
  if [ -n "$running" ] && [ "$running" != "$expected" ]; then
    start_waybar_autohide_daemon "$expected"
    return 0
  fi
  if ! pgrep -f "$WAYBAR_AUTOHIDE_PGREP_PATTERN" >/dev/null 2>&1; then
    start_waybar_autohide_daemon "$expected"
    return 0
  fi
  sync_waybar_autohide_visibility
}

apply_autohide_normal() {
  stop_waybar_autohide_daemon
  write_autohide_mode normal
  patch_waybar_autohide_config normal
  write_waybar_autohide_css visible
  show_waybar
  restart_waybar_service
}

apply_autohide_active() {
  local position="${1:-$(read_waybar_position)}"
  waybar_autohide_bin >/dev/null || {
    if command -v notify-send >/dev/null 2>&1; then
      notify-send -u normal "Waybar autohide" \
        "Falta wb_autohide. Compila: cd waybar_auto_hide && cargo build --release && cp target/release/wb_autohide ../waybar/scripts/bin/wb_autohide && deploy-configs.sh --config"
    fi
    return 1
  }

  write_autohide_mode autohide
  patch_waybar_autohide_config autohide
  stop_waybar_autohide_daemon
  restart_waybar_for_autohide
  sync_waybar_autohide_visibility
  start_waybar_autohide_daemon "$position"
}

reset_waybar_autohide_normal() {
  local waybar_config="${1:-$WAYBAR_USER_CONFIG}"
  stop_waybar_autohide_daemon
  mkdir -p "$(dirname "$WAYBAR_AUTOHIDE_STATE_FILE")"
  printf '%s\n' '{"mode": "normal"}' > "$WAYBAR_AUTOHIDE_STATE_FILE"
  WAYBAR_USER_CONFIG="$waybar_config" patch_waybar_autohide_config normal
  write_waybar_autohide_css visible
  reload_waybar_surface
  echo "Waybar: autohide → normal"
}
