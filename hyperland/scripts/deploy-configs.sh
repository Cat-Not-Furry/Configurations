#!/usr/bin/env bash
set -euo pipefail

TIMESTAMP=$(date +%Y%m%d%H%M%S)
RSYNC=$(command -v rsync || true)
SYNC_GITHUB=0

for arg in "$@"; do
  case "$arg" in
    --github) SYNC_GITHUB=1 ;;
    -h | --help)
      echo "Uso: $(basename "$0") [--github]"
      echo "  --github  Sincronizar además al repo GitHub mirror"
      exit 0
      ;;
    *)
      echo "Opción desconocida: $arg" >&2
      exit 1
      ;;
  esac
done

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib/project-paths.sh
source "$SCRIPT_DIR/lib/project-paths.sh"
resolve_project_paths "$SCRIPT_DIR"
# shellcheck source=lib/service-reload.sh
source "$SCRIPT_DIR/lib/service-reload.sh"

WAYBAR_SRC="$CONFIG_ROOT/waybar"
WOFI_SRC="$CONFIG_ROOT/wofi"
IGNIS_SRC="$CONFIG_ROOT/ignis"
HYPR_FILES=("$HYPRLAND_ROOT/hypridle.conf" "$HYPRLAND_ROOT/hyprland.conf" "$HYPRLAND_ROOT/hyprlock.conf")
HYPR_CONFD_SRC="$HYPRLAND_ROOT/conf.d"
HYPR_SCRIPTS_SRC="$HYPRLAND_ROOT/scripts"
THEMES_SRC="$HYPRLAND_ROOT/themes"
SWAYNC_SRC="$HYPRLAND_ROOT/swaync/config.json"
PALETTES_SRC="$THEMES_SRC/palettes.json"

DEST_WAYBAR="$HOME/.config/waybar"
DEST_HYPRLAND="$HOME/.config/hypr"
DEST_IGNIS="$HOME/.config/ignis"
DEST_WOFI="$HOME/.config/wofi"
DEST_SWAYNC="$HOME/.config/swaync"
CAVA_SRC="$CONFIG_ROOT/cava"
DEST_CAVA="$HOME/.config/cava"

copy_dir() {
  local src="$1" dst="$2"
  if [ ! -e "$src" ]; then
    echo "Source not found: $src"
    return 1
  fi
  mkdir -p "$dst"
  if [ -n "$RSYNC" ]; then
    rsync -a --delete "$src/" "$dst/"
  else
    cp -a "$src/." "$dst/"
  fi
  echo "Copied directory: $src -> $dst"
}

copy_file() {
  local src="$1" dst="$2"
  if [ ! -e "$src" ]; then
    echo "Source file not found: $src"
    return 1
  fi
  mkdir -p "$(dirname "$dst")"
  cp -a "$src" "$dst"
  echo "Copied file: $src -> $dst"
}

copy_cava_assets() {
  local src="$1" dst="$2"
  if [ ! -d "$src" ]; then
    echo "Warning: Cava source directory not found: $src"
    return 0
  fi
  mkdir -p "$dst"
  for item in shaders themes wayland; do
    if [ -e "$src/$item" ]; then
      if [ -d "$src/$item" ]; then
        mkdir -p "$dst/$item"
        if [ -n "$RSYNC" ]; then
          rsync -a "$src/$item/" "$dst/$item/"
        else
          cp -a "$src/$item/." "$dst/$item/"
        fi
      else
        cp -a "$src/$item" "$dst/$item"
      fi
      echo "Copied cava asset: $item"
    fi
  done
  rm -f "$dst/config.base" "$dst/config.txt" "$dst/config.bak" \
    "$dst/config.hypr" "$dst/config.log"
  rm -rf "$dst/x11"
  echo "Cava assets deployed to $dst (config activo preservado)"
}

copy_wofi_assets() {
  local src="$1" dst="$2"
  if [ ! -d "$src" ]; then
    echo "Warning: Wofi source directory not found: $src"
    return 0
  fi
  mkdir -p "$dst"
  for item in config style.base.css wayland; do
    if [ -e "$src/$item" ]; then
      if [ -d "$src/$item" ]; then
        mkdir -p "$dst/$item"
        if [ -n "$RSYNC" ]; then
          rsync -a "$src/$item/" "$dst/$item/"
        else
          cp -a "$src/$item/." "$dst/$item/"
        fi
      else
        cp -a "$src/$item" "$dst/$item"
      fi
      echo "Copied wofi asset: $item"
    fi
  done
  rm -f "$dst/style.css.bak"
  echo "Wofi assets deployed to $dst (colors/style.css activos preservados)"
}

copy_hypr_scripts() {
  local src="$1" dst="$2"
  if [ ! -d "$src" ]; then
    echo "Warning: Hypr scripts directory not found: $src"
    return 0
  fi
  mkdir -p "$dst"
  if [ -n "$RSYNC" ]; then
    rsync -a --delete --exclude='deploy-configs.sh' "$src/" "$dst/"
  else
    find "$dst" -mindepth 1 -maxdepth 1 ! -name 'deploy-configs.sh' -exec rm -rf {} +
    for f in "$src"/*; do
      [ -e "$f" ] || continue
      base="$(basename "$f")"
      [ "$base" = "deploy-configs.sh" ] && continue
      cp -a "$f" "$dst/"
    done
  fi
  echo "Copied Hypr scripts: $src -> $dst"
  rm -f "$dst/deploy-configs.sh"
}

sync_dir() {
  local src="$1" dst="$2"
  if [ ! -d "$src" ]; then
    return 0
  fi
  mkdir -p "$dst"
  if [ -n "$RSYNC" ]; then
    rsync -a "$src/" "$dst/"
  else
    mkdir -p "$dst"
    cp -a "$src/." "$dst/"
  fi
  echo "Synced directory: $src -> $dst"
}

sync_to_github_repo() {
  if ! find_github_repo_root; then
    echo "No se encontró repo GitHub (remote con 'github'); sync al repo omitido."
    return 0
  fi

  if [ "$GITHUB_REPO_ROOT" = "$CONFIG_ROOT" ]; then
    echo "Ya desplegando desde el repo GitHub ($GITHUB_REPO_ROOT); sync omitido."
    return 0
  fi

  local gh_hypr
  gh_hypr="$(github_hypr_root "$GITHUB_REPO_ROOT")"

  echo
  echo "Syncing to GitHub repo: $GITHUB_REPO_ROOT"

  sync_dir "$CONFIG_ROOT/waybar" "$GITHUB_REPO_ROOT/waybar"
  sync_dir "$CONFIG_ROOT/wofi" "$GITHUB_REPO_ROOT/wofi"
  sync_dir "$CONFIG_ROOT/ignis" "$GITHUB_REPO_ROOT/ignis"
  sync_dir "$CONFIG_ROOT/cava" "$GITHUB_REPO_ROOT/cava"

  mkdir -p "$gh_hypr"
  for f in "${HYPR_FILES[@]}"; do
    if [ -e "$f" ]; then
      copy_file "$f" "$gh_hypr/$(basename "$f")"
    fi
  done

  sync_dir "$HYPR_CONFD_SRC" "$gh_hypr/conf.d"
  sync_dir "$HYPR_SCRIPTS_SRC" "$gh_hypr/scripts"
  sync_dir "$HYPRLAND_ROOT/themes" "$gh_hypr/themes"

  if [ -f "$SWAYNC_SRC" ]; then
    mkdir -p "$gh_hypr/swaync"
    copy_file "$SWAYNC_SRC" "$gh_hypr/swaync/config.json"
  fi

  chmod +x "$gh_hypr/scripts/"*.sh 2>/dev/null || true
  echo "GitHub repo updated at $GITHUB_REPO_ROOT"
}

resolve_deploy_theme() {
  python3 - <<PY
import json
from pathlib import Path
p = Path("$PALETTES_SRC")
if p.is_file():
    d = json.loads(p.read_text())
    order = d.get("order") or []
    if order:
        print(order[0])
    else:
        print(d.get("default", "blue"))
else:
    print("blue")
PY
}

main() {
  echo "Deploying configs from $CONFIG_ROOT (hypr: $HYPRLAND_ROOT, timestamp: $TIMESTAMP)"

  if [ -d "$WAYBAR_SRC" ]; then
    copy_dir "$WAYBAR_SRC" "$DEST_WAYBAR"
    reset_waybar_position_top "$DEST_WAYBAR/config"
  else
    echo "Warning: Waybar source directory not found: $WAYBAR_SRC"
  fi

  copy_wofi_assets "$WOFI_SRC" "$DEST_WOFI"

  mkdir -p "$DEST_HYPRLAND"
  for f in "${HYPR_FILES[@]}"; do
    if [ -e "$f" ]; then
      copy_file "$f" "$DEST_HYPRLAND/$(basename "$f")"
    else
      echo "Warning: Hyprland file not found: $f"
    fi
  done

  if [ -d "$HYPR_CONFD_SRC" ]; then
    copy_dir "$HYPR_CONFD_SRC" "$DEST_HYPRLAND/conf.d"
  else
    echo "Warning: Hypr conf.d not found: $HYPR_CONFD_SRC"
  fi

  copy_hypr_scripts "$HYPR_SCRIPTS_SRC" "$DEST_HYPRLAND/scripts"
  chmod +x "$DEST_HYPRLAND/scripts/"*.sh 2>/dev/null || true

  if [ -d "$IGNIS_SRC" ]; then
    copy_dir "$IGNIS_SRC" "$DEST_IGNIS"
  else
    echo "Warning: Ignis source directory not found: $IGNIS_SRC"
  fi

  if [ -d "$THEMES_SRC" ]; then
    mkdir -p "$DEST_IGNIS/themes"
    cp -a "$THEMES_SRC/palettes.json" "$DEST_IGNIS/themes/" 2>/dev/null || true
    cp -a "$THEMES_SRC/palettes.example.json" "$DEST_IGNIS/themes/" 2>/dev/null || true
  fi

  if [ -f "$SWAYNC_SRC" ]; then
    copy_file "$SWAYNC_SRC" "$DEST_SWAYNC/config.json"
  else
    echo "Warning: swaync config not found: $SWAYNC_SRC"
  fi

  copy_cava_assets "$CAVA_SRC" "$DEST_CAVA"

  rm -f "$HOME/.cache/ignis/active-theme.json"
  ACTIVE_THEME="$(resolve_deploy_theme)"
  echo
  echo "Applying theme: $ACTIVE_THEME (primer tema en palettes.json)..."

  if [ -x "$HYPRLAND_ROOT/scripts/apply-theme.sh" ]; then
    "$HYPRLAND_ROOT/scripts/apply-theme.sh" "$ACTIVE_THEME" || {
      echo "Warning: apply-theme failed; recarga manual..."
      deploy_reload_flow
    }
  else
    echo "Warning: apply-theme.sh no encontrado; recarga manual..."
    deploy_reload_flow
  fi

  ensure_service_running swaync swaync
  ensure_service_running hypridle hypridle

  if [ "$SYNC_GITHUB" -eq 1 ]; then
    sync_to_github_repo
  else
    echo "Sync GitHub omitido (usa --github para sincronizar)."
  fi

  echo
  echo "Deploy complete."
}

main "$@"
