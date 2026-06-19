#!/usr/bin/env bash
# Generación única: cava/wayland/config.{slug} desde x11/config.bak + palettes.json
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib/project-paths.sh
source "$SCRIPT_DIR/lib/project-paths.sh"
resolve_project_paths "$SCRIPT_DIR"

PALETTES="$HYPRLAND_ROOT/themes/palettes.json"
CAVA_BASE="$CONFIG_ROOT/cava/x11/config.bak"
OUT_DIR="$CONFIG_ROOT/cava/wayland"

if [ ! -f "$PALETTES" ]; then
  echo "No se encontró $PALETTES" >&2
  exit 1
fi
if [ ! -f "$CAVA_BASE" ]; then
  echo "No se encontró $CAVA_BASE" >&2
  exit 1
fi

export PALETTES CAVA_BASE OUT_DIR

python3 <<'PY'
import json
import re
from pathlib import Path

palettes_path = Path(__import__("os").environ["PALETTES"])
cava_base = Path(__import__("os").environ["CAVA_BASE"])
out_dir = Path(__import__("os").environ["OUT_DIR"])

with open(palettes_path) as f:
    data = json.load(f)

themes = data.get("themes", {})
base_text = cava_base.read_text()

for theme_id, theme in themes.items():
    slug = theme_id.replace("_", "-")
    theme["cava"] = slug

    waybar = theme.get("waybar", {})
    label = theme.get("label", theme_id)
    c1 = waybar.get("accent", "#84A0C6")
    c2 = waybar.get("accent_light", "#A2B9D6")
    c3 = waybar.get("urgent", "#E27878")
    c4 = waybar.get("media_playing", "#a6e3a1")
    fg = c1
    bg = "black"

    color_block = (
        "[color]\n\n"
        f"background = '{bg}'\n"
        f"foreground = '{fg}'\n"
        "gradient = 1\n"
        f"gradient_color_1 = '{c1}'\n"
        f"gradient_color_2 = '{c2}'\n"
        f"gradient_color_3 = '{c3}'\n"
        f"gradient_color_4 = '{c4}'\n"
        "\n"
    )

    body = re.sub(
        r"\[color\].*?(?=\n\[smoothing\])",
        color_block.rstrip() + "\n",
        base_text,
        count=1,
        flags=re.DOTALL,
    )

    header = (
        f"# Estilo: {label} (Wayland)\n"
        f"# Slug palettes: {slug}\n"
        "# Copia manualmente a ~/.config/cava/config cuando quieras activarlo.\n"
    )

    out_path = out_dir / f"config.{slug}"
    out_dir.mkdir(parents=True, exist_ok=True)
    out_path.write_text(header + "\n" + body)
    print(f"Generado: {out_path.name}")

palettes_path.write_text(json.dumps(data, indent=2, ensure_ascii=False) + "\n")
print(f"Actualizado: {palettes_path} (campo cava en {len(themes)} temas)")
PY

# Legacy
rm -f "$CONFIG_ROOT/cava/config.base" \
  "$CONFIG_ROOT/cava/wayland/blue.conf" \
  "$CONFIG_ROOT/cava/wayland/config.hypr"

echo "Legacy eliminado (config.base, blue.conf, config.hypr)"
