#!/usr/bin/env bash
# Resuelve rutas del repo: I3/, shared/, hyprland/ (Plan 2) y layout legacy en raíz.

resolve_repo_root_from() {
  local start="$1"
  local dir="$start"
  local i=0
  while [ "$i" -lt 8 ] && [ "$dir" != "/" ]; do
    if [ -d "$dir/.git" ] && { [ -d "$dir/I3" ] || [ -d "$dir/shared" ] || [ -d "$dir/hyperland" ]; }; then
      printf '%s\n' "$dir"
      return 0
    fi
    dir="$(dirname "$dir")"
    i=$((i + 1))
  done
  return 1
}

resolve_project_paths() {
  local scripts_dir="${1:?scripts_dir requerido}"
  local repo_root=""

  HYPRLAND_ROOT="$(cd "$scripts_dir/.." && pwd)"

  if repo_root="$(resolve_repo_root_from "$scripts_dir")"; then
    :
  elif [ -d "$HYPRLAND_ROOT/../.git" ] && { [ -d "$HYPRLAND_ROOT/../I3" ] || [ -d "$HYPRLAND_ROOT/../shared" ]; }; then
    repo_root="$(cd "$HYPRLAND_ROOT/.." && pwd)"
  elif [ -d "$HYPRLAND_ROOT/hyprland/hyperland" ]; then
    repo_root="$(cd "$HYPRLAND_ROOT/../.." && pwd)"
    HYPRLAND_ROOT="$repo_root/hyprland/hyperland"
  elif [ -d "$HYPRLAND_ROOT/../hyprland/hyperland" ]; then
    repo_root="$(cd "$HYPRLAND_ROOT/.." && pwd)"
    HYPRLAND_ROOT="$repo_root/hyprland/hyperland"
  else
    repo_root="$HYPRLAND_ROOT"
    if [ -d "$HYPRLAND_ROOT/waybar" ] || [ -d "$HYPRLAND_ROOT/wofi" ] || [ -d "$HYPRLAND_ROOT/ignis" ]; then
      :
    elif [ -d "$HYPRLAND_ROOT/../waybar" ] || [ -d "$HYPRLAND_ROOT/../shared" ]; then
      repo_root="$(cd "$HYPRLAND_ROOT/.." && pwd)"
    fi
  fi

  CONFIG_ROOT="$repo_root"
  REPO_ROOT="$repo_root"

  if [ -d "$repo_root/hyprland/hyperland" ]; then
    HYPRLAND_ROOT="$repo_root/hyprland/hyperland"
  elif [ -d "$repo_root/hyperland" ]; then
    HYPRLAND_ROOT="$repo_root/hyperland"
  fi

  if [ -d "$repo_root/shared" ]; then
    SHARED_ROOT="$repo_root/shared"
  else
    SHARED_ROOT="$repo_root"
  fi

  if [ -d "$repo_root/I3" ]; then
    I3_ROOT="$repo_root/I3"
  else
    I3_ROOT="$repo_root"
  fi

  if [ -d "$SHARED_ROOT/cnf-bin" ]; then
    CNF_BIN_ROOT="$SHARED_ROOT/cnf-bin"
  elif [ -d "$repo_root/cnf-bin" ]; then
    CNF_BIN_ROOT="$repo_root/cnf-bin"
  else
    CNF_BIN_ROOT="$SHARED_ROOT/cnf-bin"
  fi

  if [ -d "$I3_ROOT/i3-wm" ]; then
    I3_WM_ROOT="$I3_ROOT/i3-wm"
  elif [ -d "$repo_root/i3-wm" ]; then
    I3_WM_ROOT="$repo_root/i3-wm"
  else
    I3_WM_ROOT="$I3_ROOT/i3-wm"
  fi

  export REPO_ROOT CONFIG_ROOT HYPRLAND_ROOT SHARED_ROOT I3_ROOT CNF_BIN_ROOT I3_WM_ROOT
}

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
      if [ -d "$candidate/I3" ] || [ -d "$candidate/shared" ] || [ -d "$candidate/hyperland" ] || [ -d "$candidate/waybar" ]; then
        CONFIG_REPO_ROOT="$candidate"
        export CONFIG_REPO_ROOT
        return 0
      fi
    done < <(find "$base" -maxdepth 4 -name .git -type d -print0 2>/dev/null)
  done

  return 1
}

find_github_repo_root() {
  find_config_repo_root
}

github_hypr_root() {
  local gh_root="${1:?github repo root}"
  if [ -d "$gh_root/hyprland/hyperland" ]; then
    echo "$gh_root/hyprland/hyperland"
  else
    echo "$gh_root/hyperland"
  fi
}

# Rutas de componentes (shared/ + hyprland/ + legacy)
path_shared() {
  local name="$1"
  if [ -d "${SHARED_ROOT:-}/$name" ]; then
    printf '%s\n' "${SHARED_ROOT}/$name"
  elif [ -d "${CONFIG_ROOT:-}/$name" ]; then
    printf '%s\n' "${CONFIG_ROOT}/$name"
  else
    printf '%s\n' "${SHARED_ROOT:-${CONFIG_ROOT:-}}/$name"
  fi
}

path_hyprland_component() {
  local name="$1"
  if [ -d "${REPO_ROOT:-}/hyprland/$name" ]; then
    printf '%s\n' "${REPO_ROOT}/hyprland/$name"
  elif [ -d "${CONFIG_ROOT:-}/$name" ]; then
    printf '%s\n' "${CONFIG_ROOT}/$name"
  else
    printf '%s\n' "${CONFIG_ROOT:-}/$name"
  fi
}
