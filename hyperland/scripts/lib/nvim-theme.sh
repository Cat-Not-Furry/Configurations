#!/usr/bin/env bash
# Genera ~/.config/nvim/lua/config/theme.generated.lua desde palettes.json (híbrido).

nvim_notify_err() {
	local msg="$1"
	echo "nvim-theme: $msg" >&2
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

activate_nvim_profile() {
	local theme_id="${1:-}"
	local palettes out

	if [ -z "$theme_id" ]; then
		echo "nvim-theme: theme_id vacío; omitido." >&2
		return 0
	fi

	palettes="$(find_palettes_file)" || {
		nvim_notify_err "No se encontró palettes.json."
		return 1
	}

	out="${HOME}/.config/nvim/lua/config/theme.generated.lua"
	if [ -e "${HOME}/.config/nvim" ] && [ ! -d "${HOME}/.config/nvim" ]; then
		nvim_notify_err "${HOME}/.config/nvim existe pero no es un directorio."
		return 1
	fi
	mkdir -p "$(dirname "$out")"

	python3 - "$theme_id" "$palettes" "$out" <<'PY'
import json
import sys
from pathlib import Path

theme_id, palettes_path, out_path = sys.argv[1:4]
data = json.loads(Path(palettes_path).read_text())
theme = data.get("themes", {}).get(theme_id)
if not theme:
	raise SystemExit(f"Tema desconocido: {theme_id}")

CUSTOM = {"blue", "green", "red", "classic"}
waybar = theme.get("waybar", {})
label = theme.get("label", theme_id)
slug = theme.get("nvim", theme.get("wofi", theme_id.replace("_", "-")))

lines = [
	"-- Generado por scripts/lib/nvim-theme.sh — no editar a mano",
	f'-- Tema: {theme_id} ({label})',
	"",
	"return {",
	f'\tmode = "{"custom" if theme_id in CUSTOM else "preset"}",',
	f'\ttheme_id = "{theme_id}",',
	f'\tcolorscheme = "tokyonight",',
]

if theme_id in CUSTOM:
	lines.append('\tstyle = "night",')
	lines.append("\twaybar = {")
	for key in (
		"background",
		"foreground",
		"accent",
		"accent_light",
		"urgent",
		"warning",
		"critical",
		"media_playing",
		"media_paused",
	):
		val = waybar.get(key)
		if val:
			lines.append(f'\t\t{key} = "{val}",')
	lines.append("\t},")
else:
	lines.append(f'\tpreset = "{slug}",')
	if waybar:
		lines.append("\twaybar = {")
		for key in ("background", "foreground", "accent", "accent_light", "urgent", "warning", "critical"):
			val = waybar.get(key)
			if val:
				lines.append(f'\t\t{key} = "{val}",')
		lines.append("\t},")

lines.append("}")
Path(out_path).write_text("\n".join(lines) + "\n")
print(f"Nvim: theme.generated.lua ← {theme_id} ({label})")
PY

	return 0
}
