#!/usr/bin/env bash
# Compila dwm y st del fork incluido en el repo.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PREFIX="${PREFIX:-/usr/local}"

usage() {
  cat <<EOF
Uso: $(basename "$0") [--prefix DIR]

Compila dwm y st (make). No instala en el sistema salvo que el Makefile lo haga.

  --prefix DIR   Prefijo de instalación (default: /usr/local)
  -h, --help     Esta ayuda

Tras compilar, añade dwm a ~/.xinitrc o arranca con startx.
Integración cnf-bin: bar/scripts/cnf-bar.sh (requiere cnf-info en PATH).

Ver: dwm-full/README.md, shared/install.sh --binaries
EOF
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --prefix)
      PREFIX="$2"
      shift 2
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      echo "Opción desconocida: $1" >&2
      exit 1
      ;;
  esac
done

build_one() {
  local dir="$1" name="$2"
  echo "==> Compilando $name en $dir"
  (cd "$dir" && make clean 2>/dev/null || true && make PREFIX="$PREFIX")
}

build_one "$SCRIPT_DIR/dwm" dwm
build_one "$SCRIPT_DIR/st" st

echo "==> Compilación terminada."
echo "    dwm: $SCRIPT_DIR/dwm/dwm"
echo "    st:  $SCRIPT_DIR/st/st"
echo "    Instala manualmente o copia a \$PATH según tu flujo (probar en VM)."
