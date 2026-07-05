#!/usr/bin/env bash
# Utilidades compartidas: tema i3 classic/iceberg (apply-i3-theme, dmenu-script1).
set -euo pipefail

resolve_config_file() {
  if [[ -n "${CNF_BIN_CONFIG:-}" && -f "$CNF_BIN_CONFIG" ]]; then
    printf '%s\n' "$CNF_BIN_CONFIG"
    return 0
  fi
  if [[ -f "${HOME}/.config/cnf-bin/config.toml" ]]; then
    printf '%s\n' "${HOME}/.config/cnf-bin/config.toml"
    return 0
  fi
  local script_dir="${1:-}"
  if [[ -n "$script_dir" ]]; then
    local sibling
    for sibling in \
      "$(cd "$script_dir/../../../shared/cnf-bin" 2>/dev/null && pwd)/config.toml" \
      "$(cd "$script_dir/../../cnf-bin" 2>/dev/null && pwd)/config.toml"; do
      if [[ -f "$sibling" ]]; then
        printf '%s\n' "$sibling"
        return 0
      fi
    done
  fi
  return 1
}

read_toml_value() {
  local file="$1" section="$2" key="$3"
  awk -v section="$section" -v key="$key" '
    /^\[/ {
      in_sec = ($0 == "[" section "]") ? 1 : 0
      next
    }
    in_sec && $1 == key {
      gsub(/^[^=]*=[[:space:]]*"/, "")
      gsub(/".*$/, "")
      gsub(/^[[:space:]]*/, "")
      print
      exit
    }
  ' "$file"
}

read_i3_theme_from_toml() {
  read_toml_value "$1" i3 theme
}

read_bumblebee_theme_from_toml() {
  read_toml_value "$1" bumblebee theme
}

resolve_i3_theme() {
  local script_dir="${1:-}"
  local explicit="${2:-}"
  local from_toml="" config_file="" local_file=""

  if [[ -n "$explicit" ]]; then
    printf '%s\n' "$explicit"
    return 0
  fi

  if config_file="$(resolve_config_file "$script_dir")"; then
    from_toml="$(read_i3_theme_from_toml "$config_file")"
    local_file="${config_file%.toml}.local.toml"
    if [[ -f "$local_file" ]]; then
      local from_local
      from_local="$(read_i3_theme_from_toml "$local_file")"
      [[ -n "$from_local" ]] && from_toml="$from_local"
    fi
  fi

  printf '%s\n' "${from_toml:-classic}"
}

bumblebee_theme_for_i3() {
  case "${1:-classic}" in
    classic | iceberg) printf '%s\n' "$1" ;;
    *) printf '%s\n' classic ;;
  esac
}

# Mapeo tema i3 (classic|iceberg) → id en palettes.json (nvim, cava, copyq).
nvim_palette_for_i3() {
  case "${1:-classic}" in
    classic) printf '%s\n' classic ;;
    iceberg) printf '%s\n' blue ;;
    *) printf '%s\n' classic ;;
  esac
}

# Mapeo tema i3 → slug de tmux/colors/{slug}.conf en sesión X11.
tmux_colors_slug_for_i3() {
  case "${1:-classic}" in
    iceberg) printf '%s\n' gray ;;
    *) printf '%s\n' classic ;;
  esac
}

_find_nvim_theme_lib() {
  local script_dir="${1:-}"
  local candidate

  for candidate in \
    "${HOME}/.config/hypr/scripts/lib/nvim-theme.sh" \
    "${HOME}/Games/configurations/hyprland/hyperland/scripts/lib/nvim-theme.sh"; do
    if [[ -f "$candidate" ]]; then
      printf '%s\n' "$candidate"
      return 0
    fi
  done

  if [[ -n "$script_dir" ]]; then
    for candidate in \
      "$(cd "$script_dir/../../../hyprland/hyperland/scripts/lib" 2>/dev/null && pwd)/nvim-theme.sh" \
      "$(cd "$script_dir/../../hyperland/scripts/lib" 2>/dev/null && pwd)/nvim-theme.sh"; do
      if [[ -f "$candidate" ]]; then
        printf '%s\n' "$candidate"
        return 0
      fi
    done
  fi
  return 1
}

activate_nvim_for_i3_theme() {
  local i3_theme="$1"
  local script_dir="${2:-}"
  local palette nvim_lib

  palette="$(nvim_palette_for_i3 "$i3_theme")"
  nvim_lib="$(_find_nvim_theme_lib "$script_dir")" || {
    echo "i3-nvim: nvim-theme.sh no encontrado; omitido." >&2
    return 1
  }

  # shellcheck source=/dev/null
  source "$nvim_lib"
  activate_nvim_profile "$palette" || return $?
  echo "i3-nvim: theme.generated.lua ← i3=${i3_theme} → palette=${palette}"
}

persist_i3_theme_config() {
  local i3_theme="$1"
  local bb_theme
  bb_theme="$(bumblebee_theme_for_i3 "$i3_theme")"
  local local_file="${HOME}/.config/cnf-bin/config.local.toml"

  python3 - "$local_file" "$i3_theme" "$bb_theme" <<'PY'
import sys
from pathlib import Path

path = Path(sys.argv[1])
i3_theme = sys.argv[2]
bb_theme = sys.argv[3]

lines = path.read_text(encoding="utf-8").splitlines() if path.exists() else []


def upsert(section: str, key: str, value: str) -> None:
    global lines
    sec_header = f"[{section}]"
    sec_start = None
    sec_end = len(lines)

    for i, line in enumerate(lines):
        if line.strip() == sec_header:
            sec_start = i
        elif sec_start is not None and line.startswith("[") and i > sec_start:
            sec_end = i
            break

    entry = f'{key} = "{value}"'

    if sec_start is None:
        if lines and lines[-1].strip():
            lines.append("")
        lines.extend([sec_header, entry])
        return

    for i in range(sec_start + 1, sec_end):
        stripped = lines[i].strip()
        if stripped.startswith(f"{key} "):
            lines[i] = entry
            return

    lines.insert(sec_end, entry)


upsert("i3", "theme", i3_theme)
upsert("bumblebee", "theme", bb_theme)
path.parent.mkdir(parents=True, exist_ok=True)
path.write_text("\n".join(lines).rstrip() + "\n", encoding="utf-8")
PY
}

# Imprime flags dmenu según tema activo (classic | iceberg).
# Tras reload/restart huérfano, i3bar puede quedar duplicado (2 filas apiladas).
ensure_single_i3bar() {
  local count
  count="$(pgrep -xc i3bar 2>/dev/null || true)"
  count="${count:-0}"
  if [[ "$count" -gt 1 ]]; then
    echo "i3: ${count} procesos i3bar; dejando uno solo" >&2
    pkill i3bar 2>/dev/null || true
    sleep 0.25
    command -v i3-msg >/dev/null 2>&1 && i3-msg reload 2>/dev/null || true
  fi
}

dmenu_theme_flags() {
  local script_dir="${1:-}"
  local theme
  theme="$(resolve_i3_theme "$script_dir")"
  case "$theme" in
    iceberg)
      printf '%s\n' '-nf "#c6c8d1" -nb "#161821" -sb "#565f75" -sf "#e2e4ea"'
      ;;
    *)
      printf '%s\n' '-nf "#eeeeee" -nb "#222222" -sb "#005818" -sf "#ffffff"'
      ;;
  esac
}
