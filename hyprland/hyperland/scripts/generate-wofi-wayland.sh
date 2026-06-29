#!/usr/bin/env bash
# Generación única: wofi/wayland/colors.{slug} + style.{slug}.css desde style.base.css + palettes
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib/project-paths.sh
source "$SCRIPT_DIR/lib/project-paths.sh"
resolve_project_paths "$SCRIPT_DIR"

PALETTES="$HYPRLAND_ROOT/themes/palettes.json"
WOFI_BASE="$CONFIG_ROOT/wofi/style.base.css"
OUT_DIR="$CONFIG_ROOT/wofi/wayland"

if [ ! -f "$PALETTES" ]; then
  echo "No se encontró $PALETTES" >&2
  exit 1
fi
if [ ! -f "$WOFI_BASE" ]; then
  echo "No se encontró $WOFI_BASE" >&2
  exit 1
fi

export PALETTES WOFI_BASE OUT_DIR

python3 <<'PY'
import json
from pathlib import Path

palettes_path = Path(__import__("os").environ["PALETTES"])
wofi_base = Path(__import__("os").environ["WOFI_BASE"])
out_dir = Path(__import__("os").environ["OUT_DIR"])

with open(palettes_path) as f:
    data = json.load(f)

themes = data.get("themes", {})
base_text = wofi_base.read_text()

for theme_id, theme in themes.items():
    slug = theme.get("wofi", theme.get("cava", theme_id.replace("_", "-")))
    theme["wofi"] = slug

    waybar = theme.get("waybar", {})
    label = theme.get("label", theme_id)
    bg = waybar.get("background", "#161821")
    fg = waybar.get("foreground", "#FFFFFF")
    accent = waybar.get("accent", "#84A0C6")
    accent_light = waybar.get("accent_light", "#A2B9D6")
    border = waybar.get("border", accent)

    colors_lines = [bg, bg, fg, fg, border, accent_light, accent_light, bg, ""]
    colors_path = out_dir / f"colors.{slug}"
    colors_path.parent.mkdir(parents=True, exist_ok=True)
    header = (
        f"# Estilo: {label} (Wayland)\n"
        f"# Slug palettes: {slug}\n"
    )
    colors_path.write_text(header + "\n".join(colors_lines))

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
    style_text = base_text
    for key, value in replacements.items():
        style_text = style_text.replace(key, value)
    style_path = out_dir / f"style.{slug}.css"
    style_path.write_text(
        f"/* Estilo: {label} (Wayland) — slug: {slug} */\n" + style_text
    )
    print(f"Generado: colors.{slug}, style.{slug}.css")

palettes_path.write_text(json.dumps(data, indent=2, ensure_ascii=False) + "\n")
print(f"Actualizado: {palettes_path} (campo wofi en {len(themes)} temas)")
PY

rm -f "$CONFIG_ROOT/wofi/colors" "$CONFIG_ROOT/wofi/style.css"
echo "Legacy eliminado (wofi/colors, wofi/style.css en raíz del repo)"
