#!/usr/bin/env bash
# Generación: tmux/colors/{slug}.conf desde colors.base.conf + palettes.json
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib/project-paths.sh
source "$SCRIPT_DIR/lib/project-paths.sh"
resolve_project_paths "$SCRIPT_DIR"

PALETTES="$HYPRLAND_ROOT/themes/palettes.json"
TMUX_BASE="$CONFIG_ROOT/tmux/colors.base.conf"
OUT_DIR="$CONFIG_ROOT/tmux/colors"

if [ ! -f "$PALETTES" ]; then
  echo "No se encontró $PALETTES" >&2
  exit 1
fi
if [ ! -f "$TMUX_BASE" ]; then
  echo "No se encontró $TMUX_BASE" >&2
  exit 1
fi

export PALETTES TMUX_BASE OUT_DIR

python3 <<'PY'
import json
from pathlib import Path

palettes_path = Path(__import__("os").environ["PALETTES"])
tmux_base = Path(__import__("os").environ["TMUX_BASE"])
out_dir = Path(__import__("os").environ["OUT_DIR"])

with open(palettes_path) as f:
    data = json.load(f)

base_text = tmux_base.read_text()
themes = data.get("themes", {})

for theme_id, theme in themes.items():
    slug = theme_id.replace("_", "-")
    if "tmux" not in theme:
        theme["tmux"] = theme.get("cava", theme.get("wofi", slug))

    waybar = theme.get("waybar", {})
    label = theme.get("label", theme_id)
    bg = waybar.get("background", "#161821")
    fg = waybar.get("foreground", "#FFFFFF")
    accent = waybar.get("accent", "#84A0C6")
    accent_light = waybar.get("accent_light", "#A2B9D6")
    border = waybar.get("border", accent)

    body = base_text
    for key, val in (
        ("{{BACKGROUND}}", bg),
        ("{{FOREGROUND}}", fg),
        ("{{ACCENT}}", accent),
        ("{{ACCENT_LIGHT}}", accent_light),
        ("{{BORDER}}", border),
    ):
        body = body.replace(key, val)

    tmux_slug = theme["tmux"]
    header = (
        f"# Generado por scripts/generate-tmux-colors.sh\n"
        f"# Tema: {theme_id} ({label}) — slug: {tmux_slug}\n"
        f"# Copia manualmente a colors.active.conf o usa apply-theme.sh\n\n"
    )

    out_path = out_dir / f"{tmux_slug}.conf"
    out_dir.mkdir(parents=True, exist_ok=True)
    out_path.write_text(header + body)
    print(f"Generado: {out_path.name}")

palettes_path.write_text(json.dumps(data, indent=2, ensure_ascii=False) + "\n")
print(f"Actualizado: {palettes_path} (campo tmux en {len(themes)} temas)")
PY

echo "Listo: perfiles en $OUT_DIR"
