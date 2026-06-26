#!/usr/bin/env bash
# Resuelve HYPRLAND_ROOT y CONFIG_ROOT relativos al script que invoca.
#
# Layout split (configurations / Games):
#   repo/
#   ├── hyperland/   → ~/.config/hypr/
#   ├── waybar/ wofi/ ignis/ …
#
# Layout monolítico (legacy): conf.d/ scripts/ themes/ en la raíz del clone.

resolve_project_paths() {
  local scripts_dir="${1:?scripts_dir requerido}"
  HYPRLAND_ROOT="$(cd "$scripts_dir/.." && pwd)"

  if [ -d "$HYPRLAND_ROOT/waybar" ] \
    || [ -d "$HYPRLAND_ROOT/wofi" ] \
    || [ -d "$HYPRLAND_ROOT/ignis" ]; then
    CONFIG_ROOT="$HYPRLAND_ROOT"
  elif [ -d "$HYPRLAND_ROOT/../waybar" ] \
    || [ -d "$HYPRLAND_ROOT/../wofi" ] \
    || [ -d "$HYPRLAND_ROOT/../ignis" ]; then
    CONFIG_ROOT="$(cd "$HYPRLAND_ROOT/.." && pwd)"
  else
    CONFIG_ROOT="$HYPRLAND_ROOT"
  fi

  export HYPRLAND_ROOT CONFIG_ROOT
}

# Repo mirror local (GitHub clone). Por defecto ~/Games/configurations.
find_config_repo_root() {
  CONFIG_REPO_ROOT="${CONFIG_REPO_ROOT:-$HOME/Games/configurations}"
  if [ -d "$CONFIG_REPO_ROOT/.git" ]; then
    export CONFIG_REPO_ROOT
    return 0
  fi

  CONFIG_REPO_ROOT=""
  local candidate remote gitdir

  for candidate in \
    "$HOME/Games/configurations" \
    "$HOME/.Games/configurations" \
    "$HOME/Games/configuration-of-my-laptop"; do
    if [ -d "$candidate/.git" ]; then
      remote="$(git -C "$candidate" remote get-url origin 2>/dev/null || true)"
      if [[ "$remote" == *github* ]]; then
        CONFIG_REPO_ROOT="$candidate"
        export CONFIG_REPO_ROOT
        return 0
      fi
    fi
  done

  for base in "$HOME/Games" "$HOME/.Games"; do
    [ -d "$base" ] || continue
    while IFS= read -r -d '' gitdir; do
      candidate="$(dirname "$gitdir")"
      remote="$(git -C "$candidate" remote get-url origin 2>/dev/null || true)"
      if [[ "$remote" != *github* ]]; then
        continue
      fi
      if [ -d "$candidate/waybar" ] || [ -d "$candidate/hyperland" ] || [ -d "$candidate/ignis" ]; then
        CONFIG_REPO_ROOT="$candidate"
        export CONFIG_REPO_ROOT
        return 0
      fi
    done < <(find "$base" -maxdepth 4 -name .git -type d -print0 2>/dev/null)
  done

  return 1
}

# Alias legacy
find_github_repo_root() {
  find_config_repo_root
}

# Hypr en el mirror: configurations/hyperland/
github_hypr_root() {
  local gh_root="${1:?github repo root}"
  echo "$gh_root/hyperland"
}
