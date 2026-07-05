#!/usr/bin/env bash
# Instala el stack i3: despliega dotfiles a ~/.config/ y opcionalmente binarios a /usr/local/bin.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
# shellcheck source=../../shared/cnf-bin/lib/require-session-user.sh
source "$REPO_ROOT/shared/cnf-bin/lib/require-session-user.sh"
require_session_user "$0" "$@"
WITH_BINARIES=0
DEPLOY_ARGS=()

usage() {
  cat <<EOF
Uso: $(basename "$0") [--binaries] [opciones de deploy-configs.sh]

Despliega la configuración i3 + componentes compartidos a ~/.config/.

  --binaries    Tras el deploy, instala cnf-bin y utilidades en /usr/local/bin
  -h, --help    Esta ayuda

Equivalente interno: deploy-configs.sh --config-i3
Flags de fondos (opcionales): --fondos, --fondos-all

Ejemplos (probar en VM):
  ./I3/scripts/install-i3.sh
  ./I3/scripts/install-i3.sh --binaries
  ./I3/scripts/install-i3.sh --config

Ver también: I3/README.md, shared/cnf-bin/README.md
EOF
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --binaries|--with-binaries)
      WITH_BINARIES=1
      shift
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      DEPLOY_ARGS+=("$1")
      shift
      ;;
  esac
done

resolve_deploy_script() {
  local root="$1" candidate
  for candidate in \
    "$root/deploy-configs.sh" \
    "$root/hyprland/hyperland/scripts/deploy-configs.sh" \
    "$root/hyperland/scripts/deploy-configs.sh"; do
    if [[ -f "$candidate" ]]; then
      printf '%s\n' "$candidate"
      return 0
    fi
  done
  return 1
}

run_deploy() {
  local script="$1"
  shift
  if [[ -x "$script" ]]; then
    "$script" "$@"
  else
    bash "$script" "$@"
  fi
}

DEPLOY=""
DEPLOY="$(resolve_deploy_script "$REPO_ROOT")" || {
  echo "install-i3: no se encontró deploy-configs.sh" >&2
  exit 1
}

echo "==> Desplegando stack i3..."
run_deploy "$DEPLOY" --config-i3 "${DEPLOY_ARGS[@]}"

if (( WITH_BINARIES )); then
  INSTALL="${REPO_ROOT}/hyprland/hyperland/scripts/install-local-binaries.sh"
  [[ -x "$INSTALL" ]] || INSTALL="${REPO_ROOT}/hyperland/scripts/install-local-binaries.sh"
  if [[ -x "$INSTALL" ]]; then
    echo "==> Instalando binarios en /usr/local/bin..."
    sudo "$INSTALL"
  else
    echo "install-i3: no se encontró install-local-binaries.sh" >&2
    exit 1
  fi
fi

echo "==> i3 listo. Revisa ~/.config/i3/ y ejecuta 'i3-msg reload' si i3 ya está activo."
