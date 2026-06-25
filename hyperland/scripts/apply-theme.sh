#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib/project-paths.sh
source "$SCRIPT_DIR/lib/project-paths.sh"
resolve_project_paths "$SCRIPT_DIR"
# shellcheck source=lib/service-reload.sh
source "$SCRIPT_DIR/lib/service-reload.sh"
# shellcheck source=lib/cava-theme.sh
source "$SCRIPT_DIR/lib/cava-theme.sh"
# shellcheck source=lib/wofi-theme.sh
source "$SCRIPT_DIR/lib/wofi-theme.sh"
# shellcheck source=lib/powerline-theme.sh
source "$SCRIPT_DIR/lib/powerline-theme.sh"
# shellcheck source=lib/nvim-theme.sh
source "$SCRIPT_DIR/lib/nvim-theme.sh"
# shellcheck source=lib/tmux-theme.sh
source "$SCRIPT_DIR/lib/tmux-theme.sh"
# shellcheck source=lib/copyq-theme.sh
source "$SCRIPT_DIR/lib/copyq-theme.sh"

THEME_ID="${1:-}"
ACTIVE_CACHE="$HOME/.cache/ignis/active-theme.json"
USER_OPTIONS="$HOME/.config/ignis/user_options.json"
HYPR_THEME_OUT="$HOME/.config/hypr/conf.d/theme.conf"
WAYBAR_COLORS_OUT="$HOME/.config/waybar/waybar-colors.css"
EWW_COLORS_OUT="$HOME/.config/eww/eww-colors.scss"
EWW_SCSS_OUT="$HOME/.config/eww/eww.scss"
THEME_NOTIFY_DEFER="${THEME_NOTIFY_DEFER:-0}"

find_palettes() {
  local candidate
  for candidate in \
    "$HOME/.config/ignis/themes/palettes.json" \
    "$HYPRLAND_ROOT/themes/palettes.json" \
    "$HOME/hyprland/themes/palettes.json" \
    "$CONFIG_ROOT/themes/palettes.json"; do
    if [ -f "$candidate" ]; then
      echo "$candidate"
      return 0
    fi
  done
  return 1
}

PALETTES="$(find_palettes)" || {
  echo "No se encontró palettes.json" >&2
  exit 1
}

if [ -z "$THEME_ID" ]; then
  if [ -f "$ACTIVE_CACHE" ]; then
    THEME_ID=$(python3 -c "import json; print(json.load(open('$ACTIVE_CACHE')).get('active',''))")
  fi
  if [ -z "$THEME_ID" ] && [ -f "$USER_OPTIONS" ]; then
    THEME_ID=$(python3 -c "
import json
try:
    d=json.load(open('$USER_OPTIONS'))
    print(d.get('theme',{}).get('active',''))
except Exception:
    print('')
")
  fi
  THEME_ID="${THEME_ID:-blue}"
fi

export PALETTES HYPR_THEME_OUT WAYBAR_COLORS_OUT EWW_COLORS_OUT EWW_SCSS_OUT THEME_ID

python3 <<'PY'
import json
import os
from pathlib import Path

palettes_path = Path(os.environ["PALETTES"])
theme_id = os.environ["THEME_ID"]
hypr_out = Path(os.environ["HYPR_THEME_OUT"])
waybar_out = Path(os.environ["WAYBAR_COLORS_OUT"])
eww_out = Path(os.environ["EWW_COLORS_OUT"])
eww_scss_out = Path(os.environ["EWW_SCSS_OUT"])

with open(palettes_path) as f:
    data = json.load(f)

themes = data.get("themes", {})
if theme_id not in themes:
    raise SystemExit(f"Tema desconocido: {theme_id}")

theme = themes[theme_id]
hypr = theme.get("hypr", {})
waybar = theme.get("waybar", {})

cache_dir = Path.home() / ".cache" / "ignis"
cache_dir.mkdir(parents=True, exist_ok=True)

order = data.get("order", list(themes.keys()))
if theme_id in order:
    next_id = order[(order.index(theme_id) + 1) % len(order)]
else:
    next_id = order[0] if order else theme_id

current_label = theme.get("label", theme_id)
next_label = themes.get(next_id, {}).get("label", next_id)

(cache_dir / "active-theme.json").write_text(
    json.dumps(
        {
            "active": theme_id,
            "label": current_label,
            "next_id": next_id,
            "next_label": next_label,
        }
    )
)

user_options = Path.home() / ".config" / "ignis" / "user_options.json"
if user_options.exists():
    try:
        opts = json.loads(user_options.read_text())
    except json.JSONDecodeError:
        opts = {}
else:
    opts = {}
opts.setdefault("theme", {})["active"] = theme_id
opts.setdefault("material", {})["colors"] = {}
user_options.parent.mkdir(parents=True, exist_ok=True)
user_options.write_text(json.dumps(opts, indent=2) + "\n")

waybar_out.parent.mkdir(parents=True, exist_ok=True)
lines = [
    "/* Generado por scripts/apply-theme.sh — no editar a mano */",
    f"@define-color waybar_bg {waybar.get('background', '#161821')};",
    f"@define-color waybar_fg {waybar.get('foreground', '#FFFFFF')};",
    f"@define-color waybar_accent {waybar.get('accent', '#84A0C6')};",
    f"@define-color waybar_accent_light {waybar.get('accent_light', '#A2B9D6')};",
    f"@define-color waybar_border {waybar.get('border', waybar.get('accent', '#84A0C6'))};",
    f"@define-color waybar_urgent {waybar.get('urgent', '#E27878')};",
    f"@define-color waybar_warning {waybar.get('warning', '#fba922')};",
    f"@define-color waybar_critical {waybar.get('critical', '#ff5555')};",
    f"@define-color waybar_media_playing {waybar.get('media_playing', '#a6e3a1')};",
    f"@define-color waybar_media_paused {waybar.get('media_paused', '#f9e2af')};",
    "",
]
waybar_out.write_text("\n".join(lines))

eww_out.parent.mkdir(parents=True, exist_ok=True)
eww_out.write_text(
    "\n".join(
        [
            "/* Generado por scripts/apply-theme.sh — no editar a mano */",
            f"$eww_bg: {waybar.get('background', '#161821')};",
            f"$eww_fg: {waybar.get('foreground', '#FFFFFF')};",
            f"$eww_accent: {waybar.get('accent', '#84A0C6')};",
            f"$eww_accent_light: {waybar.get('accent_light', '#A2B9D6')};",
            f"$eww_urgent: {waybar.get('urgent', '#E27878')};",
            f"$eww_today: {waybar.get('media_playing', '#50fa7b')};",
            "",
        ]
    )
)

eww_vars_block = "\n".join(
    [
        "/* eww-theme-vars:start */",
        f"$eww_bg: {waybar.get('background', '#161821')};",
        f"$eww_fg: {waybar.get('foreground', '#FFFFFF')};",
        f"$eww_accent: {waybar.get('accent', '#84A0C6')};",
        f"$eww_accent_light: {waybar.get('accent_light', '#A2B9D6')};",
        f"$eww_urgent: {waybar.get('urgent', '#E27878')};",
        f"$eww_today: {waybar.get('media_playing', '#50fa7b')};",
        "/* eww-theme-vars:end */",
    ]
)

if eww_scss_out.is_file():
    import re

    scss_text = eww_scss_out.read_text()
    scss_text = re.sub(
        r"/\* eww-theme-vars:start \*/.*?/\* eww-theme-vars:end \*/",
        eww_vars_block,
        scss_text,
        count=1,
        flags=re.DOTALL,
    )
    eww_scss_out.write_text(scss_text)

hypr_out.parent.mkdir(parents=True, exist_ok=True)
hypr_out.write_text(
    "# Generado por scripts/apply-theme.sh — no editar a mano\n\n"
    "general {\n"
    f"    col.active_border = {hypr.get('active_border', 'rgba(84a0c6ee) 45deg')}\n"
    f"    col.inactive_border = {hypr.get('inactive_border', 'rgba(555555aa)')}\n"
    "}\n"
)

print(f"Tema aplicado: {theme_id} ({current_label})")
print(f"Siguiente: {next_id} ({next_label})")
PY

activate_wofi_profile "$THEME_ID" || true
activate_cava_profile "$THEME_ID" || true
activate_powerline_profile "$THEME_ID" || true
restart_powerline_daemon
activate_nvim_profile "$THEME_ID" || true
activate_tmux_profile "$THEME_ID" || true
activate_copyq_profile "$THEME_ID" || true

apply_theme_reload_flow

if [ "$THEME_NOTIFY_DEFER" != "1" ]; then
  send_theme_notification
fi

echo "apply-theme.sh completado."
