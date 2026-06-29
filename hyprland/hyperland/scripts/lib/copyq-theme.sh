#!/usr/bin/env bash
# Aplicar colores CopyQ desde palettes.json (claves nativas bg/fg/sel_bg).
# CopyQ lee colores de copyq.conf [Theme] y themes/{slug}.ini; requiere reinicio.

copyq_notify_err() {
  local msg="$1"
  echo "copyq-theme: $msg" >&2
  if command -v notify-send >/dev/null 2>&1; then
    notify-send -u critical "CopyQ" "$msg" 2>/dev/null || true
  fi
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

copyq_repo_root() {
  echo "${CONFIG_ROOT:-${HYPRLAND_ROOT:-$HOME/hyprland}}/copyq"
}

copyq_repo_themes_dir() {
  echo "$(copyq_repo_root)/themes"
}

copyq_user_conf() {
  echo "${HOME}/.config/copyq/copyq.conf"
}

copyq_user_themes_dir() {
  echo "${HOME}/.config/copyq/themes"
}

copyq_lib_dir() {
  echo "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
}

copyq_apply_style_if_running() {
  local slug="$1"
  if ! pgrep -x copyq >/dev/null 2>&1; then
    echo "copyq-theme: config actualizada; CopyQ no está en ejecución."
    return 0
  fi
  if copyq config style "$slug" 2>/dev/null; then
    echo "copyq-theme: style=${slug} aplicado sin reiniciar."
    return 0
  fi
  copyq_notify_err "No se pudo aplicar style=${slug} (CopyQ en ejecución)."
  return 1
}

reload_copyq() {
  local slug="$1"

  # Por defecto no matar/recrear CopyQ (evita cuelgues/crashes durante deploy + hyprctl reload).
  # Reinicio completo solo con COPYQ_FORCE_RELOAD=1.
  if [ "${COPYQ_FORCE_RELOAD:-0}" != "1" ] || [ "${COPYQ_SKIP_RELOAD:-0}" = "1" ]; then
    copyq_apply_style_if_running "$slug"
    return $?
  fi

  local attempt

  if pgrep -x copyq >/dev/null 2>&1; then
    copyq exit 2>/dev/null || true
    for attempt in 1 2 3 4 5 6 7 8 9 10; do
      pgrep -x copyq >/dev/null || break
      sleep 0.2
    done
  fi

  copyq >/dev/null 2>&1 &
  for attempt in 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15; do
    if copyq config style "$slug" >/dev/null 2>&1; then
      return 0
    fi
    sleep 0.4
  done

  echo "copyq-theme: colores en copyq.conf; abre CopyQ (Super+X) si no se aplicaron." >&2
  return 0
}

# Regenera todos los .ini en el repo (y opcionalmente en ~/.config).
regenerate_copyq_themes() {
  local palettes script_dir repo_themes user_themes sync_user="${1:-0}"
  script_dir="$(copyq_lib_dir)"

  palettes="$(find_palettes_file)" || {
    copyq_notify_err "No se encontró palettes.json para CopyQ."
    return 1
  }

  repo_themes="$(copyq_repo_themes_dir)"
  user_themes="$(copyq_user_themes_dir)"
  mkdir -p "$repo_themes"

  python3 - "$palettes" "$repo_themes" "$script_dir" "$sync_user" "$user_themes" <<'PY'
import json
import sys
from pathlib import Path

palettes_path, repo_themes_dir, lib_dir, sync_user, user_themes_dir = sys.argv[1:6]
sys.path.insert(0, lib_dir)
from copyq_palette import build_copyq_theme, format_ini, resolve_copyq_slug

data = json.loads(Path(palettes_path).read_text())
themes = data.get("themes", {})
repo_dir = Path(repo_themes_dir)
repo_dir.mkdir(parents=True, exist_ok=True)

out_dirs = [repo_dir]
if sync_user == "1":
    user_dir = Path(user_themes_dir)
    user_dir.mkdir(parents=True, exist_ok=True)
    out_dirs.append(user_dir)

updated = False
for theme_id, theme in themes.items():
    slug = resolve_copyq_slug(theme_id, theme)
    if theme.get("copyq") != slug:
        theme["copyq"] = slug
        updated = True
    content = format_ini(theme.get("label", theme_id), build_copyq_theme(theme))
    for out_dir in out_dirs:
        (out_dir / f"{slug}.ini").write_text(content)
    print(f"Generado: {slug}.ini")

if updated:
    Path(palettes_path).write_text(
        json.dumps(data, indent=2, ensure_ascii=False) + "\n"
    )
    print(f"Actualizado: {palettes_path} (campo copyq en {len(themes)} temas)")
PY
}

activate_copyq_profile() {
  local theme_id="${1:-}"
  local palettes repo_themes user_conf user_themes slug script_dir

  if [ -z "$theme_id" ]; then
    echo "copyq-theme: theme_id vacío; omitido." >&2
    return 0
  fi

  if ! command -v copyq >/dev/null 2>&1; then
    echo "copyq-theme: copyq no instalado; omitido."
    return 0
  fi

  palettes="$(find_palettes_file)" || {
    copyq_notify_err "No se encontró palettes.json para CopyQ."
    return 1
  }

  repo_themes="$(copyq_repo_themes_dir)"
  user_conf="$(copyq_user_conf)"
  user_themes="$(copyq_user_themes_dir)"
  mkdir -p "$repo_themes" "$user_themes" "$(dirname "$user_conf")"
  script_dir="$(copyq_lib_dir)"

  slug="$(python3 - "$theme_id" "$palettes" "$repo_themes" "$user_themes" "$user_conf" "$script_dir" <<'PY'
import json
import sys
from pathlib import Path

theme_id, palettes_path, repo_themes_dir, user_themes_dir, user_conf, lib_dir = sys.argv[1:7]
sys.path.insert(0, lib_dir)
from copyq_palette import build_copyq_theme, format_ini, patch_copyq_conf, resolve_copyq_slug

data = json.loads(Path(palettes_path).read_text())
theme = data.get("themes", {}).get(theme_id)
if not theme:
    raise SystemExit(f"Tema desconocido: {theme_id}")

slug = resolve_copyq_slug(theme_id, theme)
colors = build_copyq_theme(theme)
content = format_ini(theme.get("label", theme_id), colors)
for themes_dir in (repo_themes_dir, user_themes_dir):
    Path(themes_dir, f"{slug}.ini").write_text(content)
patch_copyq_conf(Path(user_conf), colors, slug)
print(slug)
PY
)" || return 1

  reload_copyq "$slug" || return 1

  if [ "${COPYQ_FORCE_RELOAD:-0}" = "1" ]; then
    echo "CopyQ: ${slug} aplicado (reinicio completo)"
  else
    echo "CopyQ: ${slug} aplicado (config + style; Super+Shift+X si no ves colores)"
  fi
  return 0
}
