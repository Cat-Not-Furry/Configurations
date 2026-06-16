#!/usr/bin/env bash
set -euo pipefail

TIMESTAMP=$(date +%Y%m%d%H%M%S)
RSYNC=$(command -v rsync || true)

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

WAYBAR_SRC="$REPO_ROOT/waybar/waybar"
HYPR_FILES=("$REPO_ROOT/hypridle.conf" "$REPO_ROOT/hyprland.conf" "$REPO_ROOT/hyprlock.conf")
IGNIS_SRC="$REPO_ROOT/hyprland-dotfiles/ignis"

DEST_WAYBAR="$HOME/.config/waybar"
DEST_HYPRLAND="$HOME/.config/hyprland"
DEST_IGNIS="$HOME/.config/ignis"


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
    # fallback to cp
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

#!/usr/bin/env bash
set -euo pipefail

# ... código existente ...

main() {
    echo "Deploying configs (timestamp: $TIMESTAMP)"

    # Waybar
    if [ -d "$WAYBAR_SRC" ]; then
        copy_dir "$WAYBAR_SRC" "$DEST_WAYBAR"
    else
        echo "Warning: Waybar source directory not found: $WAYBAR_SRC"
    fi

    # Hyprland config files
    mkdir -p "$DEST_HYPRLAND"
    for f in "${HYPR_FILES[@]}"; do
        if [ -e "$f" ]; then
            copy_file "$f" "$DEST_HYPRLAND/$(basename "$f")"
            cp -r ~/hyprland/scripts/ ~/.config/hyprland/scripts/
        else
            echo "Warning: Hyprland file not found: $f"
        fi
    done

    # Ignis
    if [ -d "$IGNIS_SRC" ]; then
        copy_dir "$IGNIS_SRC" "$DEST_IGNIS"
    else
        echo "Warning: Ignis source directory not found: $IGNIS_SRC"
    fi

    echo
    echo "Done deploying configs."
    echo "Attempting to reload Ignis..."

    # Kill any existing ignis process and start a new one
    # `|| true` prevents `set -e` from exiting if no ignis process is found
    killall ignis 2>/dev/null || true
    ignis init &

    echo "Ignis reloaded."
    echo "Reload Hyprland using your configured command in hyprland.conf when ready (e.g., 'hyprctl reload' or a keybind)."
}

main "$@"