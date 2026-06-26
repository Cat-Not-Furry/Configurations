#!/usr/bin/env bash
# Quita copias de binarios en ~/.config (deploy legacy). No toca ~/.local/bin ni el mirror.
set -euo pipefail

remove_dir() {
  local dest="$1"
  [[ -d "$dest" ]] || return 0
  if rm -rf "$dest" 2>/dev/null; then
    echo "Eliminado: $dest"
  elif command -v sudo >/dev/null 2>&1; then
    sudo rm -rf "$dest"
    echo "Eliminado (sudo): $dest"
  else
    echo "Error: sin permisos para $dest" >&2
    return 1
  fi
}

remove_dir "${HOME}/.config/cnf-bin/bin"
remove_dir "${HOME}/.config/hypr/scripts/bin"

echo "OK — runtime en /usr/local/bin (./install-local-binaries.sh)"
