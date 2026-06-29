#!/usr/bin/env bash
# Compila cnf-info + cnf-media e instala en /usr/local/bin.
# Ejecutar desde cualquier sitio; usa rutas absolutas del repo.
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
CNF_BIN="$REPO_ROOT/shared/cnf-bin"
INSTALL="$REPO_ROOT/hyprland/hyperland/scripts/install-local-binaries.sh"

build_one() {
  local crate="$1" name="$2"
  echo "==> $name"
  (cd "$CNF_BIN/$crate" && CARGO_TARGET_DIR=./target cargo build --release)
  cp "$CNF_BIN/$crate/target/release/$name" "$CNF_BIN/bin/$name"
  chmod +x "$CNF_BIN/bin/$name"
}

build_one cnf-info cnf-info
build_one cnf-media cnf-media

if [[ -x "$INSTALL" ]]; then
  echo "==> install-local-binaries"
  "$INSTALL"
else
  echo "Instalando manualmente en /usr/local/bin..."
  sudo install -m 755 "$CNF_BIN/bin/cnf-info" "$CNF_BIN/bin/cnf-media" /usr/local/bin/
fi

echo "OK: $(command -v cnf-info) $(command -v cnf-media)"
