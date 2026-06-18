#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib/project-paths.sh
source "$SCRIPT_DIR/lib/project-paths.sh"
resolve_project_paths "$SCRIPT_DIR"

GITHUB_REPO_ROOT=""
GITHUB_HYPRL_ROOT=""
if find_github_repo_root && [ "$GITHUB_REPO_ROOT" != "$CONFIG_ROOT" ]; then
  GITHUB_HYPRL_ROOT="$(github_hypr_root "$GITHUB_REPO_ROOT")"
fi

THEME_ID="${1:-}"
ACTIVE_CACHE="$HOME/.cache/ignis/active-theme.json"
USER_OPTIONS="$HOME/.config/ignis/user_options.json"
HYPR_THEME_OUT="$HOME/.config/hypr/conf.d/theme.conf"
WAYBAR_COLORS_OUT="$HOME/.config/waybar/waybar-colors.css"
WOFI_COLORS_OUT="$HOME/.config/wofi/colors"
WOFI_STYLE_OUT="$HOME/.config/wofi/style.css"

find_wofi_template() {
  local candidate
  for candidate in \
    "$CONFIG_ROOT/wofi/style.base.css" \
    "$HYPRLAND_ROOT/wofi/style.base.css"; do
    if [ -f "$candidate" ]; then
      echo "$candidate"
      return 0
    fi
  done
  return 1
}

find_palettes() {
  local candidate
  for candidate in \
    "$HOME/.config/ignis/themes/palettes.json" \
    "$HYPRLAND_ROOT/themes/palettes.json"; do
    if [ -f "$candidate" ]; then
      echo "$candidate"
      return 0
    fi
  done
  return 1
}

WOFI_STYLE_TEMPLATE="$(find_wofi_template)" || {
  echo "No se encontró wofi/style.base.css en $CONFIG_ROOT/wofi/" >&2
  exit 1
}

PALETTES="$(find_palettes)" || {
  echo "No se encontró palettes.json en $HYPRLAND_ROOT/themes/" >&2
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

export PALETTES HYPR_THEME_OUT WAYBAR_COLORS_OUT WOFI_COLORS_OUT WOFI_STYLE_TEMPLATE WOFI_STYLE_OUT THEME_ID
export CONFIG_ROOT HYPRLAND_ROOT GITHUB_REPO_ROOT GITHUB_HYPRL_ROOT

python3 <<'PY'
import json
import os
from pathlib import Path

palettes_path = Path(os.environ["PALETTES"])
theme_id = os.environ["THEME_ID"]
hypr_out = Path(os.environ["HYPR_THEME_OUT"])
waybar_out = Path(os.environ["WAYBAR_COLORS_OUT"])
wofi_out = Path(os.environ["WOFI_COLORS_OUT"])
wofi_style_template = Path(os.environ["WOFI_STYLE_TEMPLATE"])
wofi_style_out = Path(os.environ["WOFI_STYLE_OUT"])
config_root = Path(os.environ["CONFIG_ROOT"])
hyprland_root = Path(os.environ["HYPRLAND_ROOT"])
github_root = os.environ.get("GITHUB_REPO_ROOT", "")
github_hypr = os.environ.get("GITHUB_HYPRL_ROOT", "")

with open(palettes_path) as f:
    data = json.load(f)

themes = data.get("themes", {})
if theme_id not in themes:
    raise SystemExit(f"Tema desconocido: {theme_id}")

theme = themes[theme_id]
hypr = theme.get("hypr", {})
waybar = theme.get("waybar", {})

hypr_out.parent.mkdir(parents=True, exist_ok=True)
hypr_out.write_text(
    "# Generado por scripts/apply-theme.sh — no editar a mano\n\n"
    "general {\n"
    f"    col.active_border = {hypr.get('active_border', 'rgba(84a0c6ee) 45deg')}\n"
    f"    col.inactive_border = {hypr.get('inactive_border', 'rgba(555555aa)')}\n"
    "}\n"
)

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

bg = waybar.get("background", "#161821")
fg = waybar.get("foreground", "#FFFFFF")
accent = waybar.get("accent", "#84A0C6")
accent_light = waybar.get("accent_light", "#A2B9D6")
border = waybar.get("border", accent)

wofi_lines = [bg, bg, fg, fg, border, accent_light, accent_light, bg, ""]
wofi_out.parent.mkdir(parents=True, exist_ok=True)
wofi_out.write_text("\n".join(wofi_lines))

replacements = {
    "{{WOFI_BG}}": bg,
    "{{WOFI_FG}}": fg,
    "{{WOFI_ACCENT}}": accent,
    "{{WOFI_ACCENT_LIGHT}}": accent_light,
    "{{WOFI_BORDER}}": border,
    "{{WOFI_SURFACE}}": bg,
    "{{WOFI_HOVER}}": accent_light,
    "{{WOFI_SELECTED_FG}}": bg,
}
if wofi_style_template.is_file():
    style_text = wofi_style_template.read_text()
    for key, value in replacements.items():
        style_text = style_text.replace(key, value)
    style_text = (
        "/* Generado por scripts/apply-theme.sh — no editar a mano */\n" + style_text
    )
    wofi_style_out.parent.mkdir(parents=True, exist_ok=True)
    wofi_style_out.write_text(style_text)

repo_targets = [
    (hyprland_root / "conf.d" / "theme.conf", hypr_out),
    (config_root / "waybar" / "waybar-colors.css", waybar_out),
    (config_root / "wofi" / "colors", wofi_out),
    (config_root / "wofi" / "style.css", wofi_style_out),
]
if github_root and github_hypr and github_root != str(config_root):
    gh = Path(github_root)
    gh_h = Path(github_hypr)
    repo_targets.extend([
        (gh_h / "conf.d" / "theme.conf", hypr_out),
        (gh / "waybar" / "waybar-colors.css", waybar_out),
        (gh / "wofi" / "colors", wofi_out),
        (gh / "wofi" / "style.css", wofi_style_out),
    ])
for dest, src in repo_targets:
    if dest.parent.is_dir() and src.is_file():
        dest.write_text(src.read_text())

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

order = data.get("order", list(themes.keys()))
if theme_id in order:
    next_id = order[(order.index(theme_id) + 1) % len(order)]
else:
    next_id = order[0] if order else theme_id

current_label = theme.get("label", theme_id)
next_label = themes.get(next_id, {}).get("label", next_id)

import subprocess

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
)

print(f"Tema aplicado: {theme_id} ({current_label})")
print(f"Siguiente: {next_id} ({next_label})")
PY

if command -v hyprctl >/dev/null 2>&1; then
  hyprctl reload
fi

killall waybar 2>/dev/null || true
sleep 0.4
waybar &

echo "apply-theme.sh completado."
