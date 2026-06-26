#!/usr/bin/env bash
set -euo pipefail

TIMESTAMP=$(date +%Y%m%d%H%M%S)
RSYNC=$(command -v rsync || true)
SYNC_REPO=1
DEPLOY_ALL=0

# Excluir documentación al copiar a ~/.config (solo vive en el repo)
CONFIG_DOC_EXCLUDES=(--exclude='README.md' --exclude='readme.md' --exclude='docs/' --exclude='*.md')

# Artefactos compilados / runtime: no a ~/.config; install manual en /usr/local/bin
BINARY_ARTIFACT_EXCLUDES=(
  --exclude='bin/cnf-info'
  --exclude='scripts/bin/'
  --exclude='cnf-info/target/'
  --exclude='backups/'
)

for arg in "$@"; do
  case "$arg" in
    --config | --config-only) SYNC_REPO=0 ;; # --config-only: alias legacy
    --all) DEPLOY_ALL=1 ;;
    -h | --help)
      echo "Uso: $(basename "$0") [--all] [--config]"
      echo "  Despliega el stack Hyprland a ~/.config/ y, por defecto, a \$HOME/Games/configurations"
      echo ""
      echo "  (sin flags)  ~/.config + mirror local Games/configurations + apply-theme (waybar, hypr reload, ignis)"
      echo "               cnf-bin/bin no se copia (→ /usr/local/bin manual); wb_autohide sí va a waybar/scripts/bin"
      echo "  --all        Igual + reinicia swaync al final (notificaciones)"
      echo "  --config     Solo ~/.config/ (omite sync al mirror; ahorra I/O y CPU)"
      exit 0
      ;;
    --github)
      echo "Aviso: --github está obsoleto (el sync al mirror ya es el comportamiento por defecto)." >&2
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
COPYQ_SRC="$CONFIG_ROOT/copyq"
DEST_COPYQ="$HOME/.config/copyq"
EWW_SRC="$CONFIG_ROOT/eww"
DEST_EWW="$HOME/.config/eww"
BASH_SRC="$CONFIG_ROOT/bash"
POWERLINE_SRC="$CONFIG_ROOT/powerline"
NVIM_SRC="$CONFIG_ROOT/nvim"
TMUX_SRC="$CONFIG_ROOT/tmux"
DEST_BASH="$HOME/.config/bash"
DEST_POWERLINE="$HOME/.config/powerline"
DEST_NVIM="$HOME/.config/nvim"
DEST_TMUX="$HOME/.config/tmux"
DEST_I3="$HOME/.config/i3"
FONDOS_SRC="$CONFIG_ROOT/fondos"
DEST_I3_FONDOS="$HOME/.config/i3/fondos"

# ~/.config: merge (sobrescribe/añade). Nunca --delete: preserva fondos, scripts
# locales y archivos que no están en el repo.
copy_dir_config() {
  local src="$1" dst="$2"
  shift 2
  local extra_excludes=("$@")
  if [ ! -e "$src" ]; then
    echo "Source not found: $src"
    return 1
  fi
  mkdir -p "$dst"
  if [ -n "$RSYNC" ]; then
    rsync -a "${CONFIG_DOC_EXCLUDES[@]}" "${extra_excludes[@]}" "$src/" "$dst/"
  else
    cp -a "$src/." "$dst/"
    rm -f "$dst/README.md" "$dst/readme.md" 2>/dev/null || true
    rm -rf "$dst/docs" 2>/dev/null || true
  fi
  echo "Copied (config, merge): $src -> $dst"
}

copy_dir() {
  copy_dir_config "$@"
}

copy_dir_repo() {
  local src="$1" dst="$2"
  shift 2
  local extra_excludes=("$@")
  if [ ! -d "$src" ]; then
    return 0
  fi
  mkdir -p "$dst"
  if [ -n "$RSYNC" ]; then
    rsync -a "${extra_excludes[@]}" "$src/" "$dst/"
  else
    cp -a "$src/." "$dst/"
  fi
  echo "Synced (repo): $src -> $dst"
}

sync_dir() {
  copy_dir_repo "$@"
}

sync_cnf_bin_repo() {
  local src="$CONFIG_ROOT/cnf-bin" dst="$CONFIG_REPO_ROOT/cnf-bin"
  if [ ! -d "$src" ]; then
    return 0
  fi
  mkdir -p "$dst"
  if [ -n "$RSYNC" ]; then
    rsync -a --delete \
      "${BINARY_ARTIFACT_EXCLUDES[@]}" \
      "$src/" "$dst/"
  else
    copy_dir_repo "$src" "$dst" "${BINARY_ARTIFACT_EXCLUDES[@]}"
  fi
  rm -f "$dst/bin/cnf-info" 2>/dev/null || true
  rm -rf "$dst/cnf-info/target" "$dst/backups" 2>/dev/null || true
  echo "Synced cnf-bin (scripts en bin/; sin cnf-info compilado ni target/): $src -> $dst"
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
          rsync -a "${CONFIG_DOC_EXCLUDES[@]}" "$src/$item/" "$dst/$item/"
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

copy_copyq_assets() {
  local src="$1" dst="$2"
  if [ ! -d "$src" ]; then
    echo "Warning: CopyQ source directory not found: $src"
    return 0
  fi
  mkdir -p "$dst/themes"
  for item in copyq.conf copyq-commands.ini; do
    if [ -f "$src/$item" ]; then
      copy_file "$src/$item" "$dst/$item"
    fi
  done
  if [ -d "$src/themes" ]; then
    if [ -n "$RSYNC" ]; then
      rsync -a --delete "$src/themes/" "$dst/themes/"
    else
      mkdir -p "$dst/themes"
      find "$dst/themes" -mindepth 1 -maxdepth 1 -name '*.ini' -delete
      cp -a "$src/themes/." "$dst/themes/"
    fi
    echo "Copied copyq themes (stale .ini removed)"
  fi
  echo "CopyQ assets deployed to $dst (tabs/geometría preservados)"
  local owner
  owner="$(id -un 2>/dev/null || echo "${USER:-}")"
  if [ -n "$owner" ] && [ "$owner" != "root" ] && [ -d "$dst" ]; then
    if [ "$(stat -c '%U' "$dst" 2>/dev/null)" = "root" ]; then
      chown -R "$owner:$owner" "$dst" 2>/dev/null && echo "CopyQ: permisos corregidos → $owner"
    fi
  fi
}

copy_tmux_assets() {
  local src="$1" dst="$2"
  if [ ! -d "$src" ]; then
    echo "Warning: Tmux source directory not found: $src"
    return 0
  fi
  if [ -e "$dst" ] && [ ! -d "$dst" ]; then
    echo "Error: $dst existe pero no es un directorio (rm manual requerido)." >&2
    return 1
  fi
  copy_dir_config "$src" "$dst" --exclude='tpm/' --exclude='plugins/'
  if [ ! -f "$dst/colors.active.conf" ]; then
    for fallback in "$dst/colors/blue.conf" "$dst/colors/"*.conf; do
      if [ -f "$fallback" ]; then
        cp "$fallback" "$dst/colors.active.conf"
        echo "Tmux: colors.active.conf ← $(basename "$fallback")"
        break
      fi
    done
  fi
  if [ -f "$HYPR_SCRIPTS_SRC/tmux-atajos.sh" ]; then
    cp "$HYPR_SCRIPTS_SRC/tmux-atajos.sh" "$dst/scripts/atajos.sh"
    chmod +x "$dst/scripts/atajos.sh"
  fi
  chmod +x "$dst/scripts/"*.sh 2>/dev/null || true
  rm -rf "$dst/tpm" "$dst/plugins" 2>/dev/null || true
  echo "Tmux config deployed to $dst"
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
          rsync -a "${CONFIG_DOC_EXCLUDES[@]}" "$src/$item/" "$dst/$item/"
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
    rsync -a \
      --exclude='deploy-configs.sh' \
      --exclude='sync-body-configs.sh' \
      --exclude='bin/' \
      "${CONFIG_DOC_EXCLUDES[@]}" \
      "$src/" "$dst/"
  else
    for f in "$src"/*; do
      [ -e "$f" ] || continue
      base="$(basename "$f")"
      [ "$base" = "deploy-configs.sh" ] && continue
      [ "$base" = "README.md" ] && continue
      cp -a "$f" "$dst/"
    done
  fi
  echo "Copied Hypr scripts (merge): $src -> $dst"
  rm -f "$dst/deploy-configs.sh" "$dst/README.md"
  rm -rf "$dst/bin" 2>/dev/null || true
}

copy_i3_config() {
  local src="$CONFIG_ROOT/i3-wm"
  if [ ! -d "$src" ]; then
    return 0
  fi
  # fondos/ vive bajo ~/.config/i3 pero no forma parte de i3-wm/
  copy_dir_config "$src" "$DEST_I3" --exclude='fondos/'
  chmod +x "$DEST_I3/scripts/"*.sh 2>/dev/null || true
  echo "i3 config deployed to $DEST_I3 (fondos/ no tocado)"
}

# Fondos i3: solo wallpapers del repo → ~/.config/i3/fondos/ (merge).
# fondos/other/*.7z NO se despliegan a ~/.config (quedan solo en el repo).
copy_i3_fondos_assets() {
  local img

  if [ ! -d "$FONDOS_SRC" ]; then
    return 0
  fi

  mkdir -p "$DEST_I3_FONDOS"

  shopt -s nullglob
  for img in "$FONDOS_SRC"/*.{jpg,jpeg,png,gif,webp,JPG,JPEG,PNG}; do
    [ -f "$img" ] || continue
    cp -a "$img" "$DEST_I3_FONDOS/"
  done
  shopt -u nullglob

  echo "i3 fondos: merge en $DEST_I3_FONDOS (other/*.7z solo en repo; imágenes locales preservadas)"
}

copy_cnf_bin_assets() {
  local src="$CONFIG_ROOT/cnf-bin"
  local dest="$HOME/.config/cnf-bin"

  if [ ! -d "$src" ]; then
    echo "Warning: cnf-bin source not found: $src"
    return 0
  fi

  mkdir -p "$dest/secrets" "$dest/apps"

  # Solo config/secrets/apps; binarios → /usr/local/bin (install manual).
  rm -rf "$dest/bin" 2>/dev/null || true

  if [ -f "$src/config.toml" ]; then
    copy_file "$src/config.toml" "$dest/config.toml"
  fi

  if [ ! -f "$dest/config.local.toml" ] && [ -f "$src/config.local.toml.example" ]; then
    copy_file "$src/config.local.toml.example" "$dest/config.local.toml.example"
  fi

  local secret_example
  shopt -s nullglob
  for secret_example in "$src/secrets/"*.example; do
    copy_file "$secret_example" "$dest/secrets/$(basename "$secret_example")"
  done
  shopt -u nullglob

  mkdir -p "$dest/apps/web-manager" "$dest/apps/docker-manager" "$dest/apps/print-manager"
  echo "cnf-bin deployed to $dest (config/secrets/apps; sin bin/)"
}

copy_bumblebee_status() {
  local src="$CONFIG_ROOT/bumblebee-status"
  local dest="$HOME/.config/bumblebee-status"

  if [ ! -d "$src" ]; then
    return 0
  fi

  copy_dir_config "$src" "$dest" --exclude='images/'
  chmod +x "$dest/bumblebee-status" "$dest/launch.sh" 2>/dev/null || true
  rm -rf "$dest/images" 2>/dev/null || true
  echo "bumblebee-status deployed to $dest (sin images/; solo repo)"
}

sync_to_config_repo() {
  if ! find_config_repo_root; then
    echo "No se encontró repo mirror ($HOME/Games/configurations); sync omitido."
    return 0
  fi

  if [ "$CONFIG_REPO_ROOT" = "$CONFIG_ROOT" ]; then
    echo "Ya desplegando desde el repo mirror ($CONFIG_REPO_ROOT); sync omitido."
    return 0
  fi

  echo
  echo "Syncing to config repo: $CONFIG_REPO_ROOT"

  local gh_hypr
  gh_hypr="$(github_hypr_root "$CONFIG_REPO_ROOT")"

  for component in waybar wofi ignis cava copyq eww bash powerline nvim tmux cnf-bin utilidades bumblebee-status; do
    if [ "$component" = cnf-bin ]; then
      sync_cnf_bin_repo
    else
      sync_dir "$CONFIG_ROOT/$component" "$CONFIG_REPO_ROOT/$component"
    fi
  done

  sync_dir "$CONFIG_ROOT/i3-wm" "$CONFIG_REPO_ROOT/i3-wm"
  sync_dir "$CONFIG_ROOT/session" "$CONFIG_REPO_ROOT/session"

  mkdir -p "$gh_hypr"
  for f in "${HYPR_FILES[@]}"; do
    if [ -e "$f" ]; then
      copy_file "$f" "$gh_hypr/$(basename "$f")"
    fi
  done

  sync_dir "$HYPR_CONFD_SRC" "$gh_hypr/conf.d"
  if [ -d "$HYPR_SCRIPTS_SRC" ]; then
    copy_dir_repo "$HYPR_SCRIPTS_SRC" "$gh_hypr/scripts" \
      --exclude='deploy-configs.sh' \
      --exclude='sync-body-configs.sh' \
      --exclude='bin/' \
      "${CONFIG_DOC_EXCLUDES[@]}"
    rm -rf "$gh_hypr/scripts/bin" 2>/dev/null || true
  fi
  sync_dir "$HYPRLAND_ROOT/themes" "$gh_hypr/themes"

  if [ -f "$SWAYNC_SRC" ]; then
    mkdir -p "$gh_hypr/swaync"
    copy_file "$SWAYNC_SRC" "$gh_hypr/swaync/config.json"
  fi

  # Eliminar carpeta duplicada legacy hyprland/ si existe
  if [ -d "$CONFIG_REPO_ROOT/hyprland" ] && [ "$gh_hypr" != "$CONFIG_REPO_ROOT/hyprland" ]; then
    rm -rf "$CONFIG_REPO_ROOT/hyprland"
    echo "Eliminado duplicado legacy: $CONFIG_REPO_ROOT/hyprland"
  fi

  rm -f "$CONFIG_REPO_ROOT/waybar/waybar-autohide-state.css"
  find "$CONFIG_REPO_ROOT" -type d -name '__pycache__' -prune -exec rm -rf {} + 2>/dev/null || true

  chmod +x "$gh_hypr/scripts/"*.sh 2>/dev/null || true
  if [ -f "$CONFIG_REPO_ROOT/waybar/scripts/bin/wb_autohide" ]; then
    chmod +x "$CONFIG_REPO_ROOT/waybar/scripts/bin/wb_autohide"
  fi
  echo "Config repo updated at $CONFIG_REPO_ROOT (Hypr → $gh_hypr)"
}

resolve_deploy_theme() {
  python3 - <<PY
import json
from pathlib import Path

def active_from_cache():
    cache = Path.home() / ".cache" / "ignis" / "active-theme.json"
    if cache.is_file():
        try:
            return json.loads(cache.read_text()).get("active") or ""
        except json.JSONDecodeError:
            return ""
    return ""

def active_from_user_options():
    opts = Path.home() / ".config" / "ignis" / "user_options.json"
    if opts.is_file():
        try:
            return json.loads(opts.read_text()).get("theme", {}).get("active") or ""
        except json.JSONDecodeError:
            return ""
    return ""

p = Path("$PALETTES_SRC")
active = active_from_cache() or active_from_user_options()
if p.is_file():
    d = json.loads(p.read_text())
    themes = d.get("themes", {})
    if active and active in themes:
        print(active)
    elif d.get("order"):
        print(d["order"][0])
    else:
        print(d.get("default", "blue"))
else:
    print(active or "blue")
PY
}

main() {
  DEPLOY_LOG="${XDG_CACHE_HOME:-$HOME/.cache}/hypr/deploy.log"
  mkdir -p "$(dirname "$DEPLOY_LOG")"
  log_deploy() {
    printf '[%s] %s\n' "$(date -Iseconds)" "$*" | tee -a "$DEPLOY_LOG"
  }

  log_deploy "Deploy start from $CONFIG_ROOT (hypr: $HYPRLAND_ROOT, timestamp: $TIMESTAMP)"
  echo "Deploying configs from $CONFIG_ROOT (hypr: $HYPRLAND_ROOT, timestamp: $TIMESTAMP)"
  echo "Destinos: ~/.config/ + ${CONFIG_REPO_ROOT:-$HOME/Games/configurations}"
  echo "Log: $DEPLOY_LOG"

  # shellcheck source=lib/session-env.sh
  source "$SCRIPT_DIR/lib/session-env.sh"
  remove_legacy_config_hyprland_dir

  if [ -d "$WAYBAR_SRC" ]; then
    copy_dir_config "$WAYBAR_SRC" "$DEST_WAYBAR" --exclude='waybar-autohide-state.css'
    if [ -f "$DEST_WAYBAR/scripts/bin/wb_autohide" ]; then
      chmod +x "$DEST_WAYBAR/scripts/bin/wb_autohide"
    fi
    reset_waybar_position_top "$DEST_WAYBAR/config"
    reset_waybar_autohide_normal "$DEST_WAYBAR/config"
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
    copy_dir_config "$HYPR_CONFD_SRC" "$DEST_HYPRLAND/conf.d"
  else
    echo "Warning: Hypr conf.d not found: $HYPR_CONFD_SRC"
  fi

  copy_hypr_scripts "$HYPR_SCRIPTS_SRC" "$DEST_HYPRLAND/scripts"
  chmod +x "$DEST_HYPRLAND/scripts/"*.sh 2>/dev/null || true

  if [ -d "$IGNIS_SRC" ]; then
    copy_dir_config "$IGNIS_SRC" "$DEST_IGNIS"
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
  if [ -x "$SCRIPT_DIR/generate-copyq-themes.sh" ]; then
    log_deploy "generate-copyq-themes"
    "$SCRIPT_DIR/generate-copyq-themes.sh" || echo "Warning: generate-copyq-themes.sh falló"
  fi
  log_deploy "copy_copyq_assets"
  copy_copyq_assets "$COPYQ_SRC" "$DEST_COPYQ"

  if [ -d "$EWW_SRC" ]; then
    copy_dir_config "$EWW_SRC" "$DEST_EWW"
    chmod +x "$DEST_EWW"/scripts/* 2>/dev/null || true
  else
    echo "Warning: Eww source directory not found: $EWW_SRC"
  fi

  if [ -d "$BASH_SRC" ]; then
    copy_dir_config "$BASH_SRC" "$DEST_BASH"
    if [ -f "$DEST_BASH/bashrc.hypr" ]; then
      cp -a "$DEST_BASH/bashrc.hypr" "$HOME/.bashrc"
      echo "Bash: bashrc.hypr → ~/.bashrc"
    fi
    # shellcheck source=lib/session-env.sh
    source "$SCRIPT_DIR/lib/session-env.sh"
    if [ ! -f "${HOME}/.config/bash/env.active.sh" ]; then
      write_hypr_env
    fi
  else
    echo "Warning: Bash source directory not found: $BASH_SRC"
  fi

  if [ -d "$POWERLINE_SRC" ]; then
    copy_dir_config "$POWERLINE_SRC" "$DEST_POWERLINE"
    echo "Powerline config deployed to $DEST_POWERLINE"
  else
    echo "Warning: Powerline source directory not found: $POWERLINE_SRC"
  fi

  if [ -d "$NVIM_SRC" ]; then
    if [ -e "$DEST_NVIM" ] && [ ! -d "$DEST_NVIM" ]; then
      echo "Error: $DEST_NVIM existe pero no es un directorio (rm manual requerido)." >&2
      return 1
    fi
    copy_dir_config "$NVIM_SRC" "$DEST_NVIM"
    echo "Nvim config deployed to $DEST_NVIM"
  else
    echo "Warning: Nvim source directory not found: $NVIM_SRC"
  fi

  copy_tmux_assets "$TMUX_SRC" "$DEST_TMUX" || return 1
  copy_cnf_bin_assets
  copy_bumblebee_status
  copy_i3_config
  copy_i3_fondos_assets

  rm -f "$HOME/.cache/ignis/active-theme.json"
  ACTIVE_THEME="$(resolve_deploy_theme)"
  echo
  echo "Applying theme: $ACTIVE_THEME (tema activo o fallback)..."
  export COPYQ_SKIP_RELOAD=1
  log_deploy "apply-theme start theme=${ACTIVE_THEME} COPYQ_SKIP_RELOAD=1"

  if [ -x "$HYPRLAND_ROOT/scripts/apply-theme.sh" ]; then
    if [ "$DEPLOY_ALL" -eq 1 ]; then
      THEME_NOTIFY_DEFER=1 "$HYPRLAND_ROOT/scripts/apply-theme.sh" "$ACTIVE_THEME" || {
        log_deploy "apply-theme FAILED (deploy --all)"
        echo "Warning: apply-theme failed; recarga manual..."
        deploy_reload_flow
      }
      deploy_all_post_flow
    else
      THEME_NOTIFY_DEFER=1 "$HYPRLAND_ROOT/scripts/apply-theme.sh" "$ACTIVE_THEME" || {
        log_deploy "apply-theme FAILED"
        echo "Warning: apply-theme failed; recarga manual..."
        deploy_reload_flow
      }
    fi
    log_deploy "apply-theme done"
  else
    log_deploy "apply-theme SKIPPED (script missing)"
    echo "Warning: apply-theme.sh no encontrado; recarga manual..."
    deploy_reload_flow
  fi

  ensure_service_running hypridle hypridle

  if [ "$SYNC_REPO" -eq 1 ]; then
    sync_to_config_repo
  else
    echo "Sync al repo mirror omitido (--config)."
  fi

  THEME_NOTIFY_DELAY=1 send_theme_notification
  log_deploy "theme notification sent"

  echo
  log_deploy "Deploy complete"
  echo "Deploy complete."
  echo "Logs: ${DEPLOY_LOG}"
  echo "Hyprland: ~/.config/hypr/scripts/hypr-crash-info.sh"
}

main "$@"
