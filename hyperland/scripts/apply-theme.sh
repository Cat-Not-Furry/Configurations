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

THEME_ID="${1:-}"
ACTIVE_CACHE="$HOME/.cache/ignis/active-theme.json"
USER_OPTIONS="$HOME/.config/ignis/user_options.json"
HYPR_THEME_OUT="$HOME/.config/hypr/conf.d/theme.conf"
WAYBAR_COLORS_OUT="$HOME/.config/waybar/waybar-colors.css"

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

export PALETTES HYPR_THEME_OUT WAYBAR_COLORS_OUT THEME_ID

python3 <<'PY'
import json
import os
import subprocess
from pathlib import Path

palettes_path = Path(os.environ["PALETTES"])
theme_id = os.environ["THEME_ID"]
hypr_out = Path(os.environ["HYPR_THEME_OUT"])
waybar_out = Path(os.environ["WAYBAR_COLORS_OUT"])

with open(palettes_path) as f:
    data = json.load(f)

themes = data.get("themes", {})
if theme_id not in themes:
    raise SystemExit(f"Tema desconocido: {theme_id}")

theme = themes[theme_id]
hypr = theme.get("hypr", {})
waybar = theme.get("waybar", {})

# 1. Ignis
cache_dir = Path.home() / ".cache" / "ignis"
cache_dir.mkdir(parents=True, exist_ok=True)
(cache_dir / "active-theme.json").write_text(
    json.dumps({"active": theme_id, "label": theme.get("label", theme_id)})
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
user_options.parent.mkdir(parents=True, exist_ok=True)
user_options.write_text(json.dumps(opts, indent=2) + "\n")

# 2. Waybar
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

# 3. Hyprland
hypr_out.parent.mkdir(parents=True, exist_ok=True)
hypr_out.write_text(
    "# Generado por scripts/apply-theme.sh — no editar a mano\n\n"
    "general {\n"
    f"    col.active_border = {hypr.get('active_border', 'rgba(84a0c6ee) 45deg')}\n"
    f"    col.inactive_border = {hypr.get('inactive_border', 'rgba(555555aa)')}\n"
    "}\n"
)

order = data.get("order", list(themes.keys()))
if theme_id in order:
    next_id = order[(order.index(theme_id) + 1) % len(order)]
else:
    next_id = order[0] if order else theme_id

current_label = theme.get("label", theme_id)
next_label = themes.get(next_id, {}).get("label", next_id)

subprocess.run(
    [
        "notify-send",
        "-t",
        "2500",
        "-i",
        "preferences-desktop-theme-symbolic",
        f"Tema activo: {current_label}",
        f"Siguiente: {next_label}",
    ],
    check=False,
    timeout=3,
)

print(f"Tema aplicado: {theme_id} ({current_label})")
print(f"Siguiente: {next_id} ({next_label})")
PY

activate_wofi_profile "$THEME_ID" || true
activate_cava_profile "$THEME_ID" || true

apply_theme_reload_flow

echo "apply-theme.sh completado."
