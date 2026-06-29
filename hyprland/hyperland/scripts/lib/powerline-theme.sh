#!/usr/bin/env bash
# Genera colors.json y colorschemes/shell/hypr.json desde palettes.json (bloque waybar).

powerline_notify_err() {
  local msg="$1"
  echo "powerline-theme: $msg" >&2
}

find_palettes_file() {
  local candidate
  for candidate in \
    "$HOME/.config/ignis/themes/palettes.json" \
    "${HYPRLAND_ROOT:-$HOME/hyprland}/themes/palettes.json" \
    "${CONFIG_ROOT:-$HOME/hyprland}/themes/palettes.json"; do
    if [ -f "$candidate" ]; then
      echo "$candidate"
      return 0
    fi
  done
  return 1
}

restart_powerline_daemon() {
  if ! command -v powerline-daemon >/dev/null 2>&1; then
    return 0
  fi
  powerline-daemon -q --kill 2>/dev/null || true
  powerline-daemon -q 2>/dev/null || true
  echo "Powerline: daemon reiniciado"
}

activate_powerline_profile() {
  local theme_id="${1:-}"
  local palettes dest colors_out scheme_out

  if [ -z "$theme_id" ]; then
    echo "powerline-theme: theme_id vacío; omitido." >&2
    return 0
  fi

  palettes="$(find_palettes_file)" || {
    powerline_notify_err "No se encontró palettes.json."
    return 1
  }

  dest="${HOME}/.config/powerline"
  colors_out="${dest}/colors.json"
  scheme_out="${dest}/colorschemes/shell/hypr.json"
  mkdir -p "${dest}/colorschemes/shell"

  python3 - "$theme_id" "$palettes" "$colors_out" "$scheme_out" <<'PY'
import json
import sys
from pathlib import Path

theme_id, palettes_path, colors_out, scheme_out = sys.argv[1:5]
data = json.loads(Path(palettes_path).read_text())
theme = data.get("themes", {}).get(theme_id)
if not theme:
    raise SystemExit(f"Tema desconocido: {theme_id}")

wb = theme.get("waybar", {})

def hex6(value: str, default: str) -> str:
    v = (value or default).lstrip("#").lower()
    if len(v) == 8:
        v = v[2:]
    return v[:6]


def cterm_pair(hex_color: str, fallback: int) -> list:
    return [fallback, hex_color]


bg = hex6(wb.get("background"), "161821")
fg = hex6(wb.get("foreground"), "ffffff")
accent = hex6(wb.get("accent"), "84a0c6")
accent_light = hex6(wb.get("accent_light"), "a2b9d6")
urgent = hex6(wb.get("urgent"), "e27878")
critical = hex6(wb.get("critical"), "ff5555")
warning = hex6(wb.get("warning"), "fba922")

colors = {
    "colors": {
        "hypr_bg": cterm_pair(bg, 233),
        "hypr_fg": cterm_pair(fg, 231),
        "hypr_accent": cterm_pair(accent, 123),
        "hypr_accent_light": cterm_pair(accent_light, 117),
        "hypr_urgent": cterm_pair(urgent, 203),
        "hypr_critical": cterm_pair(critical, 203),
        "hypr_warning": cterm_pair(warning, 214),
        "hypr_surface": cterm_pair(bg, 236),
    },
    "gradients": {},
}

scheme = {
    "name": f"Hyprland {theme_id}",
    "groups": {
        "user": {"fg": "hypr_fg", "bg": "hypr_accent", "attrs": ["bold"]},
        "hostname": {"fg": "hypr_bg", "bg": "hypr_accent_light", "attrs": ["bold"]},
        "ssh": {"fg": "hypr_bg", "bg": "hypr_urgent", "attrs": ["bold"]},
        "uptime": {"fg": "hypr_fg", "bg": "hypr_surface", "attrs": []},
        "docker": {"fg": "hypr_bg", "bg": "hypr_accent", "attrs": ["bold"]},
        "docker_idle": {"fg": "hypr_fg", "bg": "hypr_surface", "attrs": []},
        "background": {"fg": "hypr_fg", "bg": "hypr_surface", "attrs": []},
        "background:divider": {"fg": "hypr_accent_light", "bg": "hypr_surface", "attrs": []},
        "information:additional": {"fg": "hypr_accent_light", "bg": "hypr_surface", "attrs": []},
        "information:regular": {"fg": "hypr_fg", "bg": "hypr_surface", "attrs": ["bold"]},
        "information:priority": {"fg": "hypr_bg", "bg": "hypr_warning", "attrs": ["bold"]},
        "critical:failure": {"fg": "hypr_fg", "bg": "hypr_critical", "attrs": ["bold"]},
        "critical:success": {"fg": "hypr_bg", "bg": "hypr_accent", "attrs": []},
        "cwd": "information:additional",
        "cwd:current_folder": "information:regular",
        "cwd:divider": {"fg": "hypr_accent_light", "bg": "hypr_surface", "attrs": []},
        "virtualenv": {"fg": "hypr_bg", "bg": "hypr_accent_light", "attrs": []},
        "branch": {"fg": "hypr_accent_light", "bg": "hypr_bg", "attrs": []},
        "branch_clean": {"fg": "hypr_accent_light", "bg": "hypr_bg", "attrs": []},
        "branch_dirty": {"fg": "hypr_fg", "bg": "hypr_urgent", "attrs": ["bold"]},
        "branch:divider": {"fg": "hypr_accent", "bg": "hypr_bg", "attrs": []},
        "stash": "branch_dirty",
        "stash:divider": "branch:divider",
        "exit_fail": "critical:failure",
        "exit_success": "critical:success",
        "jobnum": "information:priority",
        "continuation": "cwd",
        "continuation:current": "cwd:current_folder",
    },
}

Path(colors_out).write_text(json.dumps(colors, indent=2) + "\n")
Path(scheme_out).write_text(json.dumps(scheme, indent=2) + "\n")
print(f"Powerline: tema {theme_id} → {colors_out}")
PY

  return 0
}
