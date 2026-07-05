#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib/project-paths.sh
source "$SCRIPT_DIR/lib/project-paths.sh"
resolve_project_paths "$SCRIPT_DIR"
# shellcheck source=../../../shared/cnf-bin/lib/require-session-user.sh
source "${CNF_BIN_ROOT}/lib/require-session-user.sh"
require_session_user "$0" "$@"

TIMESTAMP=$(date +%Y%m%d%H%M%S)
RSYNC=$(command -v rsync || true)
SYNC_REPO=1
DEPLOY_ALL=0
DEPLOY_TARGET=all
DEPLOY_FONDOS=0
DEPLOY_FONDOS_ALL=0

# Excluir documentación al copiar a ~/.config (solo vive en el repo)
CONFIG_DOC_EXCLUDES=(--exclude='README.md' --exclude='readme.md' --exclude='docs/' --exclude='*.md')

# Artefactos compilados / runtime: no a ~/.config; install manual en /usr/local/bin
BINARY_ARTIFACT_EXCLUDES=(
  --exclude='bin/cnf-info'
  --exclude='bin/cnf-media'
  --exclude='scripts/bin/'
  --exclude='cnf-info/target/'
  --exclude='cnf-media/target/'
  --exclude='backups/'
)

for arg in "$@"; do
  case "$arg" in
    --config-hypr)
      SYNC_REPO=0
      if [ "$DEPLOY_TARGET" = i3 ]; then
        echo "Error: --config-hypr y --config-i3 son mutuamente excluyentes." >&2
        exit 1
      fi
      DEPLOY_TARGET=hypr
      ;;
    --config-i3)
      SYNC_REPO=0
      if [ "$DEPLOY_TARGET" = hypr ]; then
        echo "Error: --config-hypr y --config-i3 son mutuamente excluyentes." >&2
        exit 1
      fi
      DEPLOY_TARGET=i3
      ;;
    --config | --config-only)
      SYNC_REPO=0
      if [ "$DEPLOY_TARGET" = all ]; then
        DEPLOY_TARGET=all
      fi
      ;;
    --all) DEPLOY_ALL=1 ;;
    --fondos)
      DEPLOY_FONDOS=1
      ;;
    --fondos-all)
      DEPLOY_FONDOS=1
      DEPLOY_FONDOS_ALL=1
      ;;
    -h | --help)
      cat <<EOF
Uso: $(basename "$0") [--all] [--config] [--config-hypr | --config-i3] [--fondos | --fondos-all]

Despliega dotfiles del repo a ~/.config/ (y mirror local por defecto).

  (sin flags)       Hyprland + i3 + compartidos → ~/.config + mirror + recarga según sesión
  --config          Igual que sin flags pero sin mirror (~/.config only)
  --config-hypr     Solo stack Hyprland + compartidos; recarga waybar/hypr/ignis (si activo)
  --config-i3       Solo stack i3 + compartidos; recarga i3/bumblebee (si activo)
  --all             Con recarga Hyprland: reinicia swaync al final
  --fondos          Copia wallpapers del repo → ~/.config/fondos/ (merge; sin other/)
  --fondos-all      Igual que --fondos e incluye shared/fondos/other/ (sin README)

Compartidos (cnf-bin, tmux, nvim, powerline, copyq): se despliegan en cualquier modo.
cnf-bin/bin no se copia a ~/.config (→ /usr/local/bin manual).
EOF
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

WAYBAR_SRC="$(path_hyprland_component waybar)"
WOFI_SRC="$(path_shared wofi)"
IGNIS_SRC="$(path_shared ignis)"
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
CAVA_SRC="$(path_shared cava)"
DEST_CAVA="$HOME/.config/cava"
COPYQ_SRC="$(path_shared copyq)"
DEST_COPYQ="$HOME/.config/copyq"
EWW_SRC="$(path_shared eww)"
DEST_EWW="$HOME/.config/eww"
BASH_SRC="$(path_shared bash)"
POWERLINE_SRC="$(path_hyprland_component powerline)"
NVIM_SRC="$(path_shared nvim)"
TMUX_SRC="$(path_shared tmux)"
I3_WM_SRC="${I3_WM_ROOT:-$CONFIG_ROOT/i3-wm}"
BUMBLEBEE_SRC="${I3_ROOT:-$CONFIG_ROOT}/bumblebee-status"
POLYBAR_SRC="$(path_shared polybar)"
CNF_BIN_SRC="${CNF_BIN_ROOT:-$CONFIG_ROOT/cnf-bin}"
DEST_BASH="$HOME/.config/bash"
DEST_POWERLINE="$HOME/.config/powerline"
DEST_NVIM="$HOME/.config/nvim"
DEST_TMUX="$HOME/.config/tmux"
DEST_I3="$HOME/.config/i3"
DEST_POLYBAR="$HOME/.config/polybar"
FONDOS_SRC="$(path_shared fondos)"
DEST_FONDOS="$HOME/.config/fondos"

# shellcheck source=lib/service-reload.sh
source "$SCRIPT_DIR/lib/service-reload.sh"

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

fix_config_tree_owner_if_root() {
  local dst="$1"
  local label="${2:-config}"
  local owner
  owner="$(deploy_config_owner)"
  if [ -n "$owner" ] && [ "$owner" != "root" ] && [ -d "$dst" ]; then
    if [ "$(stat -c '%U' "$dst" 2>/dev/null)" = "root" ]; then
      if chown -R "$owner:$owner" "$dst" 2>/dev/null; then
        echo "${label}: permisos corregidos → $owner"
      elif command -v sudo >/dev/null 2>&1 && sudo -n chown -R "$owner:$owner" "$dst" 2>/dev/null; then
        echo "${label}: permisos corregidos (sudo) → $owner"
      else
        echo "Aviso: ${label}: $dst pertenece a root; ejecuta: sudo chown -R ${owner}:${owner} ${dst}" >&2
      fi
    fi
  fi
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
  local src="$CNF_BIN_SRC" dst="$CONFIG_REPO_ROOT/shared/cnf-bin"
  if [ ! -d "$src" ]; then
    src="$CONFIG_ROOT/cnf-bin"
    dst="$CONFIG_REPO_ROOT/cnf-bin"
  fi
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
  rm -f "$dst/bin/cnf-info" "$dst/bin/cnf-media" 2>/dev/null || true
  rm -rf "$dst/cnf-info/target" "$dst/cnf-media/target" "$dst/backups" 2>/dev/null || true
  echo "Synced cnf-bin (scripts en bin/; sin binarios compilados ni target/): $src -> $dst"
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
  echo "Cava assets deployed to $dst (wayland; config activo preservado)"
}

copy_cava_x11_assets() {
  local src="$1/x11" dst="$2/x11"
  if [ ! -d "$src" ]; then
    echo "Warning: Cava X11 source not found: $src"
    return 0
  fi
  mkdir -p "$dst"
  if [ -n "$RSYNC" ]; then
    rsync -a "${CONFIG_DOC_EXCLUDES[@]}" "$src/" "$dst/"
  else
    cp -a "$src/." "$dst/"
  fi
  echo "Cava X11 assets deployed to $dst"
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
  fix_config_tree_owner_if_root "$dst" "CopyQ"
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
  local src="$I3_WM_SRC"
  if [ ! -d "$src" ]; then
    return 0
  fi
  # fondos/ legado bajo i3-wm/ (hoy viven en ~/.config/fondos)
  copy_dir_config "$src" "$DEST_I3" \
    --exclude='fondos/' \
    --exclude='conf.d/07-gaps_borders.conf' \
    --exclude='conf.d/05-bbar.conf'
  chmod +x "$DEST_I3/scripts/"*.sh 2>/dev/null || true
  fix_config_tree_owner_if_root "$DEST_I3" "i3"
  echo "i3 config deployed to $DEST_I3"
}

# Fondos: solo con --fondos o --fondos-all → ~/.config/fondos/ (merge).
# --fondos-all incluye other/ (sin README ni *.md).
copy_fondos_assets() {
  local img item base

  if [ "$DEPLOY_FONDOS" -eq 0 ]; then
    return 0
  fi

  if [ ! -d "$FONDOS_SRC" ]; then
    echo "Warning: Fondos source not found: $FONDOS_SRC"
    return 0
  fi

  mkdir -p "$DEST_FONDOS"

  shopt -s nullglob
  for img in "$FONDOS_SRC"/*.{jpg,jpeg,png,gif,webp,JPG,JPEG,PNG}; do
    [ -f "$img" ] || continue
    cp -a "$img" "$DEST_FONDOS/"
  done
  shopt -u nullglob
  echo "Fondos: merge en $DEST_FONDOS (wallpapers raíz)"

  if [ "$DEPLOY_FONDOS_ALL" -eq 0 ]; then
    return 0
  fi

  if [ ! -d "$FONDOS_SRC/other" ]; then
    echo "Warning: Fondos other/ no encontrado en $FONDOS_SRC"
    return 0
  fi

  mkdir -p "$DEST_FONDOS/other"
  shopt -s nullglob
  for item in "$FONDOS_SRC/other"/*; do
    [ -e "$item" ] || continue
    base="$(basename "$item")"
    case "$base" in
      README.md | readme.md | *.md) continue ;;
    esac
    cp -a "$item" "$DEST_FONDOS/other/"
  done
  shopt -u nullglob
  echo "Fondos: merge en $DEST_FONDOS/other (--fondos-all)"
}

copy_cnf_bin_assets() {
  local src="$CNF_BIN_SRC"
  local dest="$HOME/.config/cnf-bin"

  if [ ! -d "$src" ]; then
    echo "Warning: cnf-bin source not found: $src"
    return 0
  fi

  mkdir -p "$dest/secrets" "$dest/apps" "$dest/lib"

  # Solo config/secrets/apps/lib; binarios → /usr/local/bin (install manual).
  rm -rf "$dest/bin" 2>/dev/null || true

  if [ -d "$src/lib" ]; then
    copy_dir_config "$src/lib" "$dest/lib"
    chmod +x "$dest/lib/"*.sh 2>/dev/null || true
  fi

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
  local src="$BUMBLEBEE_SRC"
  local dest="$HOME/.config/bumblebee-status"

  if [ ! -d "$src" ]; then
    return 0
  fi

  copy_dir_config "$src" "$dest" --exclude='images/'
  chmod +x "$dest/bumblebee-status" "$dest/launch.sh" 2>/dev/null || true
  rm -rf "$dest/images" 2>/dev/null || true
  echo "bumblebee-status deployed to $dest (sin images/; solo repo)"
}

copy_polybar_assets() {
  local src="$POLYBAR_SRC"
  if [ ! -d "$src" ]; then
    return 0
  fi
  copy_dir_config "$src" "$DEST_POLYBAR"
  for ini in config.ini config.classic.ini config.iceberg.ini; do
    [ -f "$src/$ini" ] && cp -a "$src/$ini" "$DEST_POLYBAR/$ini"
  done
  chmod +x "$DEST_POLYBAR/launch.sh" "$DEST_POLYBAR/scripts/"*.sh 2>/dev/null || true
  echo "polybar deployed to $DEST_POLYBAR"
}

deploy_shared_assets() {
  log_deploy "deploy_shared_assets"
  copy_cnf_bin_assets
  copy_tmux_assets "$TMUX_SRC" "$DEST_TMUX" || return 1

  if [ "$DEPLOY_TARGET" != i3 ] && [ -d "$POWERLINE_SRC" ]; then
    copy_dir_config "$POWERLINE_SRC" "$DEST_POWERLINE"
    echo "Powerline config deployed to $DEST_POWERLINE"
  elif [ "$DEPLOY_TARGET" = i3 ]; then
    echo "Powerline: omitido (solo stack Hyprland)"
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

  log_deploy "copy_copyq_assets"
  copy_copyq_assets "$COPYQ_SRC" "$DEST_COPYQ"
}

deploy_hypr_bash_profile() {
  local session
  session="$(read_deploy_session_mode)"
  if [ "$session" = x11 ] || [ "$session" = i3 ]; then
    echo "Bash Hyprland: omitido (sesión X11/i3 activa)."
    return 0
  fi
  if [ -f "$DEST_BASH/bashrc.hypr" ]; then
    cp -a "$DEST_BASH/bashrc.hypr" "$HOME/.bashrc"
    echo "Bash: bashrc.hypr → ~/.bashrc"
  fi
  # shellcheck source=lib/session-env.sh
  source "$SCRIPT_DIR/lib/session-env.sh"
  if [ ! -f "${HOME}/.config/bash/env.active.sh" ]; then
    write_hypr_env
  fi
}

deploy_i3_bash_profile() {
  local session
  session="$(read_deploy_session_mode)"
  if [ "$session" = hyprland ] || [ "$session" = wayland ]; then
    echo "Bash X11: omitido (sesión Hyprland activa)."
    return 0
  fi
  if [ -f "$DEST_BASH/bashrc.x11" ]; then
    cp -a "$DEST_BASH/bashrc.x11" "$HOME/.bashrc"
    echo "Bash: bashrc.x11 → ~/.bashrc"
  fi
}

deploy_hypr_assets() {
  log_deploy "deploy_hypr_assets"
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

  if [ -d "$EWW_SRC" ]; then
    copy_dir_config "$EWW_SRC" "$DEST_EWW"
    chmod +x "$DEST_EWW"/scripts/* 2>/dev/null || true
  else
    echo "Warning: Eww source directory not found: $EWW_SRC"
  fi

  if [ -d "$BASH_SRC" ]; then
    copy_dir_config "$BASH_SRC" "$DEST_BASH"
    deploy_hypr_bash_profile
  else
    echo "Warning: Bash source directory not found: $BASH_SRC"
  fi
}

deploy_i3_assets() {
  log_deploy "deploy_i3_assets"
  if [ -d "$BASH_SRC" ]; then
    copy_dir_config "$BASH_SRC" "$DEST_BASH"
    deploy_i3_bash_profile
  fi

  if [ -d "$THEMES_SRC" ]; then
    mkdir -p "$DEST_IGNIS/themes"
    cp -a "$THEMES_SRC/palettes.json" "$DEST_IGNIS/themes/" 2>/dev/null || true
    cp -a "$THEMES_SRC/palettes.example.json" "$DEST_IGNIS/themes/" 2>/dev/null || true
  fi

  copy_cava_x11_assets "$CAVA_SRC" "$DEST_CAVA"
  copy_i3_config
  copy_bumblebee_status
  copy_polybar_assets

  activate_i3_theme_profile || true
  log_deploy "activate_i3_theme_profile done"
}

deploy_hypr_post() {
  if ! command -v hyprctl >/dev/null 2>&1 || ! hyprctl version >/dev/null 2>&1; then
    return 0
  fi

  export DEPLOY_QUIET=1
  rm -f "$HOME/.cache/ignis/active-theme.json"
  ACTIVE_THEME="$(resolve_deploy_theme)"
  export COPYQ_SKIP_RELOAD=1
  log_deploy "apply-theme start theme=${ACTIVE_THEME}"

  if [ -x "$HYPRLAND_ROOT/scripts/apply-theme.sh" ]; then
    if [ "$DEPLOY_ALL" -eq 1 ]; then
      THEME_NOTIFY_DEFER=1 "$HYPRLAND_ROOT/scripts/apply-theme.sh" "$ACTIVE_THEME" >>"$DEPLOY_LOG" 2>&1 || {
        log_deploy "apply-theme FAILED (deploy --all)"
        deploy_reload_flow >>"$DEPLOY_LOG" 2>&1 || true
      }
      deploy_all_post_flow >>"$DEPLOY_LOG" 2>&1 || true
    else
      THEME_NOTIFY_DEFER=1 "$HYPRLAND_ROOT/scripts/apply-theme.sh" "$ACTIVE_THEME" >>"$DEPLOY_LOG" 2>&1 || {
        log_deploy "apply-theme FAILED"
        deploy_reload_flow >>"$DEPLOY_LOG" 2>&1 || true
      }
    fi
    log_deploy "apply-theme done"
  else
    log_deploy "apply-theme SKIPPED (script missing)"
    deploy_reload_flow >>"$DEPLOY_LOG" 2>&1 || true
  fi

  ensure_service_running hypridle hypridle
  THEME_NOTIFY_DELAY=1 send_theme_notification
  log_deploy "hypr post done"
}

deploy_i3_post() {
  activate_i3_theme_profile || activate_x11_shared_themes || true

  if ! pgrep -x i3 >/dev/null 2>&1; then
    log_deploy "deploy_i3_post: i3 no activo; tema escrito en disco"
    return 0
  fi

  deploy_i3_reload_flow
  log_deploy "deploy_i3_reload_flow done"
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

  sync_shared_repo() {
    local component src dst
    for component in cnf-bin tmux nvim utilidades copyq bash session fondos cava wofi ignis eww; do
      if [ "$component" = cnf-bin ]; then
        sync_cnf_bin_repo
        continue
      fi
      src="$(path_shared "$component")"
      dst="$CONFIG_REPO_ROOT/shared/$component"
      [ -d "$src" ] && sync_dir "$src" "$dst"
    done
    if [ "$DEPLOY_TARGET" != i3 ] && [ -d "$POWERLINE_SRC" ]; then
      sync_dir "$POWERLINE_SRC" "$CONFIG_REPO_ROOT/hyprland/powerline" 2>/dev/null \
        || sync_dir "$POWERLINE_SRC" "$CONFIG_REPO_ROOT/powerline"
    fi
  }

  case "$DEPLOY_TARGET" in
    hypr)
      sync_shared_repo
      for component in waybar; do
        src="$(path_hyprland_component "$component")"
        dst="$CONFIG_REPO_ROOT/hyprland/$component"
        [ -d "$src" ] && sync_dir "$src" "$dst"
      done
      ;;
    i3)
      sync_shared_repo
      [ -d "$I3_WM_SRC" ] && sync_dir "$I3_WM_SRC" "$CONFIG_REPO_ROOT/I3/i3-wm"
      [ -d "$BUMBLEBEE_SRC" ] && sync_dir "$BUMBLEBEE_SRC" "$CONFIG_REPO_ROOT/I3/bumblebee-status"
      [ -d "$POLYBAR_SRC" ] && sync_dir "$POLYBAR_SRC" "$CONFIG_REPO_ROOT/shared/polybar"
      src="$(path_shared session)"
      [ -d "$src" ] && sync_dir "$src" "$CONFIG_REPO_ROOT/shared/session" 2>/dev/null || true
      ;;
    *)
      sync_shared_repo
      for component in waybar; do
        src="$(path_hyprland_component "$component")"
        [ -d "$src" ] && sync_dir "$src" "$CONFIG_REPO_ROOT/hyprland/$component"
      done
      [ -d "$I3_WM_SRC" ] && sync_dir "$I3_WM_SRC" "$CONFIG_REPO_ROOT/I3/i3-wm"
      [ -d "$BUMBLEBEE_SRC" ] && sync_dir "$BUMBLEBEE_SRC" "$CONFIG_REPO_ROOT/I3/bumblebee-status"
      [ -d "$POLYBAR_SRC" ] && sync_dir "$POLYBAR_SRC" "$CONFIG_REPO_ROOT/shared/polybar"
      ;;
  esac

  if [ "$DEPLOY_TARGET" = i3 ]; then
    echo "Config repo updated at $CONFIG_REPO_ROOT (modo i3)"
    return 0
  fi

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

  if [ "$DEPLOY_TARGET" = all ]; then
    [ -d "$I3_WM_SRC" ] && sync_dir "$I3_WM_SRC" "$CONFIG_REPO_ROOT/I3/i3-wm"
    src="$(path_shared session)"
    [ -d "$src" ] && sync_dir "$src" "$CONFIG_REPO_ROOT/shared/session"
  fi

  # Eliminar carpetas legacy en raíz del mirror si existen
  for legacy in cnf-bin i3-wm bumblebee-status polybar hyperland waybar; do
    if [ -d "$CONFIG_REPO_ROOT/$legacy" ] && [ -d "$CONFIG_REPO_ROOT/shared" ] || [ -d "$CONFIG_REPO_ROOT/I3" ] || [ -d "$CONFIG_REPO_ROOT/hyprland" ]; then
      case "$legacy" in
        hyperland)
          [ "$gh_hypr" != "$CONFIG_REPO_ROOT/hyperland" ] && [ -d "$CONFIG_REPO_ROOT/hyperland/hyperland" ] && rm -rf "$CONFIG_REPO_ROOT/hyperland" 2>/dev/null || true
          ;;
        cnf-bin|i3-wm|bumblebee-status|polybar|waybar)
          [ -d "$CONFIG_REPO_ROOT/shared/$legacy" ] || [ -d "$CONFIG_REPO_ROOT/I3/$legacy" ] || [ -d "$CONFIG_REPO_ROOT/hyprland/$legacy" ] && rm -rf "$CONFIG_REPO_ROOT/$legacy" 2>/dev/null || true
          ;;
      esac
    fi
  done

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

run_deploy_post() {
  local session
  session="$(read_deploy_session_mode)"

  case "$DEPLOY_TARGET" in
    hypr)
      deploy_hypr_post
      ;;
    i3)
      deploy_i3_post
      ;;
    all)
      case "$session" in
        x11 | i3)
          deploy_i3_post
          ;;
        hyprland | wayland)
          deploy_hypr_post
          ;;
        *)
          echo "Recarga: sesión desconocida; omitida (usa --config-hypr o --config-i3)."
          ;;
      esac
      ;;
  esac
}

main() {
  DEPLOY_LOG="${XDG_CACHE_HOME:-$HOME/.cache}/hypr/deploy.log"
  mkdir -p "$(dirname "$DEPLOY_LOG")"
  log_deploy() {
    printf '[%s] %s\n' "$(date -Iseconds)" "$*" >>"$DEPLOY_LOG"
  }

  log_deploy "Deploy start target=${DEPLOY_TARGET} from $CONFIG_ROOT"
  case "$DEPLOY_TARGET" in
    hypr) echo "Deploy Hyprland → ~/.config/" ;;
    i3) echo "Deploy i3 → ~/.config/" ;;
    *) echo "Deploy configs → ~/.config/" ;;
  esac

  # shellcheck source=lib/session-env.sh
  source "$SCRIPT_DIR/lib/session-env.sh"

  if [ "$DEPLOY_TARGET" = hypr ] || [ "$DEPLOY_TARGET" = all ]; then
    if [ -x "$SCRIPT_DIR/generate-copyq-themes.sh" ]; then
      log_deploy "generate-copyq-themes"
      "$SCRIPT_DIR/generate-copyq-themes.sh" || echo "Warning: generate-copyq-themes.sh falló"
    fi
  fi

  deploy_shared_assets

  case "$DEPLOY_TARGET" in
    hypr)
      deploy_hypr_assets
      ;;
    i3)
      deploy_i3_assets
      ;;
    all)
      deploy_hypr_assets
      deploy_i3_assets
      ;;
  esac

  copy_fondos_assets

  run_deploy_post

  if [ "$SYNC_REPO" -eq 1 ]; then
    sync_to_config_repo
  fi

  log_deploy "Deploy complete (target=${DEPLOY_TARGET})"
  case "$DEPLOY_TARGET" in
    hypr) echo "Listo (Hyprland). Log: $DEPLOY_LOG" ;;
    i3) echo "Listo (i3). Log: $DEPLOY_LOG" ;;
    *) echo "Listo. Log: $DEPLOY_LOG" ;;
  esac
}

main "$@"
