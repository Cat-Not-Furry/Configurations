#!/usr/bin/env bash
# tmux-atajos.sh — Referencia de atajos tmux (Hyprland dotfiles, es-MX)
#
# Uso: ./tmux-atajos.sh [sección]
#   Secciones: intro, nav, sesiones, ventanas, paneles, copia, config, comandos, all, -h|--help

set -euo pipefail

if [[ -t 1 ]]; then
  BOLD=$'\033[1m'
  DIM=$'\033[2m'
  CYAN=$'\033[36m'
  RESET=$'\033[0m'
else
  BOLD= DIM= CYAN= RESET=
fi

section() { printf '\n%s%s%s\n' "$BOLD" "$1" "$RESET"; }
item()    { printf '  %-28s %s\n' "$1" "$2"; }
note()    { printf '  %s%s%s\n' "$DIM" "→ $1" "$RESET"; }
prefix()  { printf '  %s%s%s\n' "$CYAN" "  [$1]" "$RESET"; }

show_intro() {
  section "Introducción"
  cat <<'EOF'
  Prefijo tmux: Ctrl+Space (no Ctrl+b).
  Arranque manual: foot → tm  (alias en bashrc.hypr / bashrc.x11)

  Modos sin prefijo:
    Alt+Space        → modo paneles (luego flechas entre splits)
    Alt+Shift+Space  → modo ventanas (luego flechas entre pestañas)
EOF
}

show_nav() {
  section "Navegación rápida"
  item "Alt+Space → flecha"     "Foco entre paneles (splits)"
  item "Alt+Shift+Space → flecha" "Cambiar pestaña tmux"
  item "Escape / q (en modo nav)" "Salir del modo navegación"
  note "Up/Left = anterior ventana; Down/Right = siguiente (modo ventanas)"
}

show_sesiones() {
  section "Sesiones"
  item "tm"                        "attach main || new -s main"
  item "tmux new -s nombre"        "Nueva sesión"
  item "tmux attach -t nombre"     "Conectar"
  item "tmux ls"                   "Listar sesiones"
  prefix "Ctrl+Space"
  item "d"                         "Desconectar (sesión sigue)"
  item "s"                         "Elegir sesión"
  item "\$"                        "Renombrar sesión"
  item "tmux kill-session -t X"  "Cerrar sesión"
}

show_ventanas() {
  section "Ventanas (pestañas)"
  prefix "Ctrl+Space"
  item "c"      "Nueva ventana"
  item "&"      "Cerrar ventana"
  item "n / p"  "Siguiente / anterior"
  item "1-9"    "Ir a ventana N"
  item "w"      "Lista de ventanas"
  item ","      "Renombrar ventana"
  item "l"      "Última ventana"
}

show_paneles() {
  section "Paneles (splits)"
  prefix "Ctrl+Space"
  item "|"      "Split horizontal"
  item "-"      "Split vertical"
  item "x"      "Cerrar panel"
  item "z"      "Zoom panel"
  item "{" "}"  "Mover panel"
  item "q"      "Numerar paneles"
  item "o"      "Siguiente panel"
}

show_copia() {
  section "Copiar / scroll"
  prefix "Ctrl+Space"
  item "["        "Modo copia"
  item "Space"    "Iniciar selección (en modo copia)"
  item "Enter"    "Copiar"
  item "]"        "Pegar buffer"
  item "q"        "Salir modo copia"
}

show_config() {
  section "Configuración"
  prefix "Ctrl+Space"
  item "r"   "Recargar tmux.conf"
  item "?"   "Ayuda de atajos (tmux)"
  item ":"   "Línea de comandos"
  note "Barra inferior: user@host | sesión | pac/aur/flat | hora"
  note "Contadores pacman/AUR/flatpak: cache 1 h (~/.cache/tmux/pkg-updates)"
  note "Tema: apply-theme.sh → colors.active.conf"
}

show_comandos() {
  section "Comandos shell"
  item "tmux list-keys -N"  "Atajos con descripción"
  item "tmux list-commands" "Comandos tmux disponibles"
  item "man tmux"           "Manual"
  item "cat"                "Probar teclas en foot (fuera de tmux)"
}

show_all() {
  show_intro
  show_nav
  show_sesiones
  show_ventanas
  show_paneles
  show_copia
  show_config
  show_comandos
}

usage() {
  cat <<EOF
Uso: $(basename "$0") [sección]

Secciones: intro, nav, sesiones, ventanas, paneles, copia, config, comandos, all
EOF
}

main() {
  local sec="${1:-all}"
  case "$sec" in
    intro) show_intro ;;
    nav | navegacion) show_nav ;;
    sesiones | sesion) show_sesiones ;;
    ventanas | ventana) show_ventanas ;;
    paneles | panel) show_paneles ;;
    copia | copy) show_copia ;;
    config | conf) show_config ;;
    comandos | cmd) show_comandos ;;
    all) show_all ;;
    -h | --help) usage ;;
    *) echo "Sección desconocida: $sec" >&2; usage >&2; exit 1 ;;
  esac
}

main "${1:-all}"
