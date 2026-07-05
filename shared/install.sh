#!/usr/bin/env bash
# Instala componentes compartidos: config cnf-bin y/o binarios en /usr/local/bin.
# Para dotfiles completos (i3 o Hyprland) usa I3/scripts/install-i3.sh o hyprland/scripts/install-hypr.sh.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
# shellcheck source=cnf-bin/lib/require-session-user.sh
source "$SCRIPT_DIR/cnf-bin/lib/require-session-user.sh"
require_session_user "$0" "$@"
CNF_BIN="$SCRIPT_DIR/cnf-bin"
CONFIG_ONLY=0
WITH_BINARIES=0
WITH_BUILD=0

usage() {
  cat <<EOF
Uso: $(basename "$0") [--config-only] [--binaries] [--build]

Instala partes compartidas del repo (no despliega i3/Hyprland completos).

  --config-only   Copia config.toml y libs de cnf-bin a ~/.config/cnf-bin/
  --binaries      Instala scripts de cnf-bin/bin y utilidades en /usr/local/bin
  --build         Compila cnf-info + cnf-media (Rust) antes de --binaries
  -h, --help      Esta ayuda

Por defecto (sin flags): --config-only + --binaries.

Ejemplos (probar en VM):
  ./shared/install.sh
  ./shared/install.sh --build --binaries
  ./shared/cnf-bin/build-install.sh    # atajo: compilar Rust + instalar todo

Ver: shared/README.md, shared/cnf-bin/README.md
EOF
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --config-only)
      CONFIG_ONLY=1
      shift
      ;;
    --binaries|--with-binaries)
      WITH_BINARIES=1
      shift
      ;;
    --build)
      WITH_BUILD=1
      shift
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      echo "Opción desconocida: $1" >&2
      usage >&2
      exit 1
      ;;
  esac
done

# Sin flags explícitos: config + binarios
if [[ $CONFIG_ONLY -eq 0 && $WITH_BINARIES -eq 0 && $WITH_BUILD -eq 0 ]]; then
  CONFIG_ONLY=1
  WITH_BINARIES=1
fi

if (( CONFIG_ONLY )); then
  DEST="$HOME/.config/cnf-bin"
  mkdir -p "$DEST"
  echo "==> cnf-bin config → $DEST"
  install -m 644 "$CNF_BIN/config.toml" "$DEST/"
  [[ -f "$CNF_BIN/config.local.toml" ]] && install -m 644 "$CNF_BIN/config.local.toml" "$DEST/" || true
  if [[ -d "$CNF_BIN/lib" ]]; then
    mkdir -p "$DEST/lib"
    install -m 644 "$CNF_BIN/lib/"*.sh "$DEST/lib/" 2>/dev/null || true
  fi
  if [[ -d "$CNF_BIN/secrets" ]]; then
    mkdir -p "$DEST/secrets"
    for f in "$CNF_BIN/secrets/"*.example; do
      [[ -f "$f" ]] || continue
      base="$(basename "$f" .example)"
      if [[ ! -f "$DEST/secrets/$base" ]]; then
        install -m 600 "$f" "$DEST/secrets/$base"
        echo "  Creado $DEST/secrets/$base desde .example (revisa credenciales)"
      fi
    done
  fi
fi

if (( WITH_BUILD )); then
  echo "==> Compilando cnf-info + cnf-media..."
  "$CNF_BIN/build-install.sh"
  exit 0
fi

if (( WITH_BINARIES )); then
  INSTALL="${REPO_ROOT}/hyprland/hyperland/scripts/install-local-binaries.sh"
  [[ -x "$INSTALL" ]] || INSTALL="${REPO_ROOT}/hyperland/scripts/install-local-binaries.sh"
  if [[ -x "$INSTALL" ]]; then
    echo "==> Binarios → /usr/local/bin"
    sudo "$INSTALL"
  else
    echo "Instalando manualmente desde $CNF_BIN/bin/..."
    sudo install -d /usr/local/bin
    sudo install -m 755 "$CNF_BIN/bin"/* /usr/local/bin/ 2>/dev/null || true
  fi
fi

echo "==> shared instalado."
