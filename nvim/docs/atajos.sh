#!/usr/bin/env bash
# atajos.sh — Referencia de atajos de teclado para esta config LazyVim (es-MX)
#
# Generado: 2026-06-20
# Fuentes:
#   - https://lazyvim.github.io/keymaps
#   - ~/.local/share/nvim/lazy/LazyVim/
#   - nvim/lua/config/ + nvim/lua/plugins/
#
# Uso: ./atajos.sh [sección]
#   Secciones: intro, esenciales, lazyvim, snacks, lsp, otros, config, plugins,
#              dashboard, conflicts, tips, all, -h|--help

set -euo pipefail

# ── Colores ──────────────────────────────────────────────────────────────────
if [[ -t 1 ]]; then
  BOLD=$'\033[1m'
  DIM=$'\033[2m'
  CYAN=$'\033[36m'
  YELLOW=$'\033[33m'
  GREEN=$'\033[32m'
  RESET=$'\033[0m'
else
  BOLD= DIM= CYAN= YELLOW= GREEN= RESET=
fi

section() { printf '\n%s%s%s\n' "$BOLD" "$1" "$RESET"; }
item()    { printf '  %-22s %s\n' "$1" "$2"; }
note()    { printf '  %s%s%s\n' "$DIM" "→ $1" "$RESET"; }
prefix()  { printf '  %s%s%s\n' "$CYAN" "  [$1]" "$RESET"; }

# ── Intro ────────────────────────────────────────────────────────────────────
show_intro() {
  section "Introducción"
  cat <<'EOF'
  Esta config usa LazyVim con descripciones traducidas al español (es-MX).
  Las teclas literales se muestran entre <>; en Neovim aparecen igual.

  <leader>       Tecla líder (por defecto: Espacio)
  <localleader>  Líder local (por defecto: \)

  Which-key: pulsa <leader> (o cualquier prefijo) y verás un popup con
  los atajos disponibles. En sesión, muchas descripciones ya están en español.

  Picker activo: Snacks (install_version 8 en lazyvim.json).
  Extras: prettier, json, php, test.core (neotest).
EOF
}

# ── Cheat sheet ──────────────────────────────────────────────────────────────
show_esenciales() {
  section "Atajos esenciales (cheat sheet)"
  note "Los 15 atajos más útiles del día a día"
  item "<leader><space>" "Buscar archivos (dir. raíz)"
  item "<leader>,"        "Buffers abiertos"
  item "<leader>/"        "Buscar texto / grep (dir. raíz)"
  item "<leader>sg"       "Grep (dir. raíz)"
  item "<leader>ff"       "Buscar archivos (dir. raíz)"
  item "<leader>fp"       "Proyectos"
  item "<C-s>"            "Guardar archivo"
  item "<S-h> / <S-l>"    "Buffer anterior / siguiente (bufferline)"
  item "<leader>bd"       "Eliminar buffer"
  item "gd"               "Ir a definición (picker LSP)"
  item "gr"               "Referencias (picker LSP)"
  item "<leader>ca"       "Acción de código"
  item "<leader>cr"       "Renombrar símbolo"
  item "<leader>cf"       "Formatear"
  item "<c-/>"            "Terminal (dir. raíz)"
}

# ── LazyVim general ──────────────────────────────────────────────────────────
show_lazyvim() {
  section "LazyVim — General"
  note "Fuente: lazyvim/config/keymaps.lua + lazyvim.github.io/keymaps"

  prefix "<leader>f — archivo"
  item "<leader>fn"  "Archivo nuevo"
  item "<leader>cf"  "Formatear"

  prefix "<leader>g — git (picker / lazygit)"
  item "<leader>gg"  "LazyGit (dir. raíz) — ver conflictos"
  item "<leader>gG"  "LazyGit (dir. actual)"
  item "<leader>gl"  "Historial Git"
  item "<leader>gb"  "Blame de línea Git"
  item "<leader>gf"  "Historial del archivo Git"
  item "<leader>gB"  "Abrir en Git"
  item "<leader>gY"  "Copiar URL de Git"

  prefix "<leader>b — buffers"
  item "<leader>bb"  "Cambiar al otro buffer"
  item "<leader>bd"  "Eliminar buffer"
  item "<leader>bo"  "Eliminar otros buffers"
  item "<leader>bi"  "Eliminar buffers invisibles"
  item "<leader>bD"  "Eliminar buffer y ventana"

  prefix "<leader>u — interfaz / toggles"
  item "<leader>us"  "Ortografía"
  item "<leader>uw"  "Ajuste de línea"
  item "<leader>ud"  "Diagnósticos"
  item "<leader>ul"  "Números de línea"
  item "<leader>uT"  "Treesitter"
  item "<leader>ub"  "Fondo oscuro"
  item "<leader>uz"  "Modo zen"
  item "<leader>uZ"  "Zoom"
  item "<leader>uh"  "Sugerencias inline"

  prefix "<leader> — terminal / ventanas / pestañas"
  item "<leader>fT"       "Terminal (dir. actual)"
  item "<leader>ft"       "Terminal (dir. raíz)"
  item "<c-/>"            "Terminal / enfocar (dir. raíz)"
  item "<leader>-"        "Dividir ventana abajo"
  item "<leader>|"       "Dividir ventana a la derecha"
  item "<leader>wd"      "Cerrar ventana"
  item "<leader><tab>]"  "Pestaña siguiente"
  item "<leader><tab>d"  "Cerrar pestaña"

  prefix "Diagnósticos"
  item "<leader>cd"  "Diagnósticos de línea"
  item "]d / [d"     "Siguiente / anterior diagnóstico"
  item "]e / [e"     "Siguiente / anterior error"

  prefix "Navegación"
  item "<C-h/j/k/l>"  "Mover entre ventanas"
  item "<C-s>"        "Guardar archivo"
  item "n / N"        "Siguiente / anterior resultado de búsqueda"
  item "<leader>l"   "Lazy (plugins)"
  item "<leader>qq"  "Salir de todo"
}

# ── Snacks picker ────────────────────────────────────────────────────────────
show_snacks() {
  section "Snacks — Picker y búsqueda"
  note "Fuente: lazyvim/plugins/extras/editor/snacks_picker.lua"

  prefix "Accesos rápidos"
  item "<leader><space>" "Buscar archivos (dir. raíz)"
  item "<leader>,"       "Buffers"
  item "<leader>/"       "Grep (dir. raíz)"
  item "<leader>:"       "Historial de comandos"
  item "<leader>."       "Alternar buffer scratch"
  item "<leader>S"       "Elegir buffer scratch"

  prefix "<leader>f — buscar / explorar"
  item "<leader>ff"  "Buscar archivos (dir. raíz)"
  item "<leader>fF"  "Buscar archivos (dir. actual)"
  item "<leader>fg"  "Buscar archivos (git)"
  item "<leader>fc"  "Buscar archivo de config"
  item "<leader>fr"  "Recientes"
  item "<leader>fR"  "Recientes (dir. actual)"
  item "<leader>fp"  "Proyectos"
  item "<leader>fb"  "Buffers"
  item "<leader>fB"  "Buffers (todos)"
  item "<leader>fe"  "Explorador (dir. raíz)"
  item "<leader>fE"  "Explorador (dir. actual)"
  item "<leader>e"   "Explorador (dir. raíz) — ver conflictos con Harpoon"
  item "<leader>E"   "Explorador (dir. actual)"

  prefix "<leader>s — búsqueda avanzada"
  item "<leader>sg"  "Grep (dir. raíz)"
  item "<leader>sG"  "Grep (dir. actual)"
  item "<leader>sw"  "Selección o palabra (dir. raíz)"
  item "<leader>sW"  "Selección o palabra (dir. actual)"
  item "<leader>sB"  "Buscar en buffers abiertos"
  item "<leader>sb"  "Líneas del buffer"
  item "<leader>sk"  "Atajos (keymaps)"
  item "<leader>sh"  "Páginas de ayuda"
  item "<leader>sd"  "Diagnósticos"
  item "<leader>sD"  "Diagnósticos del buffer"
  item "<leader>sa"  "Autocomandos"
  item "<leader>st"  "Pendientes (todo)"
  item "<leader>sT"  "Pendientes/Fix/Fixme"
  item "<leader>su"  "Historial de cambios (undotree)"
  item "<leader>sR"  "Reanudar última búsqueda"
  item '<leader>s"'  "Registros"
  item "<leader>sp"  "Buscar spec de plugin"
  item "<leader>uC"  "Temas de color"

  prefix "<leader>g — git (picker)"
  item "<leader>gs"  "Estado Git"
  item "<leader>gS"  "Stash Git"
  item "<leader>gd"  "Diff Git (fragmentos)"
  item "<leader>gD"  "Diff Git (origin)"
  item "<leader>gi"  "Issues de GitHub (abiertos)"
  item "<leader>gp"  "PRs de GitHub (abiertos)"

  prefix "Notificaciones"
  item "<leader>n"   "Historial de notificaciones"
  item "<leader>un"  "Descartar todas las notificaciones"
}

# ── LSP ──────────────────────────────────────────────────────────────────────
show_lsp() {
  section "LSP — Navegación y acciones"
  note "Fuente: lazyvim/plugins/lsp/init.lua + snacks_picker (gd/gr vía picker)"
  note "Con Snacks picker, gd/gr abren el picker LSP en lugar del salto directo"

  prefix "Navegación"
  item "gd"   "Ir a definición"
  item "gr"   "Referencias"
  item "gI"   "Ir a implementación"
  item "gy"   "Ir a definición de tipo"
  item "gD"   "Ir a declaración"
  item "K"    "Documentación flotante (hover)"
  item "gK"   "Ayuda de firma"
  item "<c-k>" "Ayuda de firma (modo insert)"

  prefix "<leader>c — código"
  item "<leader>ca"  "Acción de código"
  item "<leader>cr"  "Renombrar"
  item "<leader>co"  "Organizar imports"
  item "<leader>cc"  "Ejecutar codelens"
  item "<leader>cC"  "Actualizar codelens"
  item "<leader>cA"  "Acción de origen (source action)"
  item "<leader>cR"  "Renombrar archivo"
  item "<leader>cl"  "Info LSP"
  item "<leader>cs"  "Símbolos (Trouble)"
  item "<leader>cS"  "Referencias/definiciones (Trouble)"
  item "<leader>cF"  "Formatear lenguajes inyectados (conform)"

  prefix "Símbolos (picker)"
  item "<leader>ss"  "Símbolos LSP"
  item "<leader>sS"  "Símbolos LSP del workspace"
  item "gai"         "Llamadas entrantes"
  item "gao"         "Llamadas salientes"

  prefix "Referencias en documento"
  item "]] / [["     "Referencia siguiente / anterior"
  item "<a-n> / <a-p>" "Referencia siguiente / anterior (alt)"
}

# ── Otros plugins LazyVim ────────────────────────────────────────────────────
show_otros() {
  section "Flash, Mason, sesiones, Noice, tests"
  note "Fuente: lazyvim/plugins/editor.lua, util.lua, ui.lua, extras/test/core"

  prefix "flash.nvim"
  item "s"          "Flash (salto)"
  item "S"          "Flash Treesitter"
  item "r"          "Flash remoto (modo operador)"
  item "R"          "Búsqueda Treesitter"
  item "<c-space>"  "Selección incremental Treesitter"
  item "<c-s>"      "Alternar búsqueda Flash (modo cmdline)"

  prefix "mason.nvim"
  item "<leader>cm"  "Mason (instalar LSP, linters, formatters)"

  prefix "persistence.nvim — sesiones"
  item "<leader>qs"  "Restaurar sesión"
  item "<leader>qS"  "Elegir sesión"
  item "<leader>ql"  "Restaurar última sesión"
  item "<leader>qd"  "No guardar sesión actual"

  prefix "noice.nvim"
  item "<leader>sn"   "Grupo noice"
  item "<leader>snl"  "Último mensaje (Noice)"
  item "<leader>snh"  "Historial Noice"
  item "<leader>sna"  "Todo Noice"
  item "<leader>snd"  "Descartar notificaciones"
  item "<leader>snt"  "Selector Noice"
  item "<c-f> / <c-b>" "Desplazar adelante / atrás (popup LSP)"

  prefix "neotest (extra test.core)"
  item "<leader>tr"  "Ejecutar test más cercano"
  item "<leader>tt"  "Ejecutar archivo de tests"
  item "<leader>tT"  "Ejecutar todos los tests"
  item "<leader>tl"  "Repetir último test"
  item "<leader>ts"  "Alternar resumen"
  item "<leader>to"  "Mostrar salida"
  item "<leader>td"  "Depurar test más cercano (dap)"

  prefix "grug-far.nvim"
  item "<leader>sr"  "Buscar y reemplazar"
}

# ── Config local ───────────────────────────────────────────────────────────────
show_config() {
  section "Config local (nvim/lua/config/)"
  note "Atajos definidos en tu dotfiles, no en LazyVim base"

  prefix "keymaps.lua"
  item "<leader>vi"  "Ver imagen (visor externo: feh/imv)"

  prefix "locale.lua — toggles redefinidos (mismas teclas, desc. en español)"
  item "<leader>us"  "Ortografía"
  item "<leader>uw"  "Ajuste de línea"
  item "<leader>ud"  "Diagnósticos"
  item "<leader>uz"  "Modo zen"
  item "<leader>uZ"  "Zoom"
  note "Lista completa: config/locale.lua → setup_snacks_toggles()"
}

# ── Plugins locales ──────────────────────────────────────────────────────────
show_plugins() {
  section "Plugins locales (nvim/lua/plugins/)"
  note "Configuración propia del repo"

  prefix "harpoon.nvim"
  item "<leader>a"  "Harpoon: marcar archivo"
  item "<leader>e"  "Harpoon: ver lista"
  item "<leader>1"  "Harpoon: ir a 1"
  item "<leader>2"  "Harpoon: ir a 2"
  item "<leader>3"  "Harpoon: ir a 3"
  item "<leader>4"  "Harpoon: ir a 4"

  prefix "bufferline.nvim"
  item "<S-h>"       "Buffer anterior (BufferLine)"
  item "<S-l>"       "Buffer siguiente (BufferLine)"
  item "<leader>bp"  "Fijar buffer"
  item "<leader>bP"  "Eliminar buffers no fijados"

  prefix "lazygit.nvim"
  item "<leader>gg"  "LazyGit (dir. actual) — ver conflictos"

  prefix "which-key (locale.lua)"
  item "<leader>v"   "Grupo imagen"
  note "Grupos traducidos: pestañas, código, git, búsqueda, interfaz, etc."
}

# ── Dashboard ────────────────────────────────────────────────────────────────
show_dashboard() {
  section "Dashboard (pantalla de inicio)"
  note "Fuente: config/locale/dashboard.lua — teclas en la pantalla inicial"

  item "f"  "Buscar archivo"
  item "n"  "Archivo nuevo"
  item "p"  "Proyectos"
  item "g"  "Buscar texto"
  item "r"  "Archivos recientes"
  item "c"  "Configuración"
  item "s"  "Restaurar sesión"
  item "x"  "Extras de LazyVim"
  item "l"  "Lazy (plugins)"
  item "q"  "Salir"
}

# ── Conflictos ─────────────────────────────────────────────────────────────────
show_conflicts() {
  section "Colisiones conocidas en esta config"
  note "El último plugin cargado gana; lazy.nvim resuelve por orden de spec"

  printf '\n'
  printf '  %-18s %-28s %-28s\n' "Tecla" "LazyVim base" "Tu config"
  printf '  %-18s %-28s %-28s\n' "─────" "────────────" "─────────"
  printf '  %-18s %-28s %-28s\n' "<S-h> / <S-l>" "bprevious / bnext" "BufferLine prev/next"
  printf '  %-18s %-28s %-28s\n' "<leader>e" "Explorador Snacks" "Harpoon: ver lista"
  printf '  %-18s %-28s %-28s\n' "<leader>a" "(sin uso base)" "Harpoon: marcar archivo"
  printf '  %-18s %-28s %-28s\n' "<leader>1–4" "(sin uso base)" "Harpoon: ir a marcador"
  printf '  %-18s %-28s %-28s\n' "<leader>gg" "Snacks.lazygit (raíz)" "lazygit.nvim (cwd)"

  note "Para explorador usa <leader>fe o <leader>fE si <leader>e está en Harpoon"
  note "Para LazyGit en raíz del repo prueba <leader>gG (Snacks, dir. actual)"
}

# ── Tips ───────────────────────────────────────────────────────────────────────
show_tips() {
  section "Consejos"
  item ":Lazy"         "Gestionar plugins (instalar, actualizar, deshabilitar)"
  item ":LazyExtras"   "Activar/desactivar extras de LazyVim"
  item ":Mason"        "Instalar servidores LSP, linters y formatters"
  item ":checkhealth"  "Diagnóstico de Neovim (clipboard, LSP, treesitter…)"
  item ":WhichKey"     "Ver todos los grupos de atajos"
  item "<leader>?"     "Atajos del buffer actual (which-key)"
  item "<leader>sk"    "Listar todos los keymaps (Snacks picker)"
  item "<leader>l"     "Abrir Lazy desde cualquier buffer"
  note "Descripciones en sesión: config/locale.lua traduce atajos al cargar"
  note "Clipboard: config/clipboard.lua detecta Wayland (wl-copy) o X11 (xclip)"
}

# ── Ayuda ──────────────────────────────────────────────────────────────────────
show_help() {
  section "atajos.sh — Referencia de atajos LazyVim (es-MX)"
  cat <<'EOF'
  Uso: ./atajos.sh [sección]

  Secciones:
    intro       Leyenda (<leader>, which-key, picker activo)
    esenciales  Cheat sheet (~15 atajos más usados)
    lazyvim     General LazyVim (buffers, git, toggles, terminal…)
    snacks      Snacks picker / búsqueda / explorador
    lsp         Navegación y acciones LSP
    otros       Flash, Mason, sesiones, Noice, neotest
    config      Atajos en nvim/lua/config/
    plugins     Atajos en nvim/lua/plugins/
    dashboard   Teclas del dashboard de inicio
    conflicts   Colisiones conocidas (Harpoon, bufferline, lazygit)
    tips        Comandos útiles (:Lazy, :Mason, :checkhealth)
    all         Todas las secciones
    -h, --help  Esta ayuda

  Ejemplos:
    ./atajos.sh esenciales
    ./atajos.sh snacks
    ./atajos.sh conflicts
EOF
}

show_all() {
  show_intro
  show_esenciales
  show_lazyvim
  show_snacks
  show_lsp
  show_otros
  show_config
  show_plugins
  show_dashboard
  show_conflicts
  show_tips
}

# ── Main ───────────────────────────────────────────────────────────────────────
main() {
  local cmd="${1:-}"

  case "$cmd" in
    intro)      show_intro ;;
    esenciales) show_esenciales ;;
    lazyvim)    show_lazyvim ;;
    snacks)     show_snacks ;;
    lsp)        show_lsp ;;
    otros)      show_otros ;;
    config)     show_config ;;
    plugins)    show_plugins ;;
    dashboard)  show_dashboard ;;
    conflicts)  show_conflicts ;;
    tips)       show_tips ;;
    all)        show_all ;;
    -h|--help|help|"") show_help ;;
    *)
      printf '%sError:%s sección desconocida: %s\n' "$YELLOW" "$RESET" "$cmd" >&2
      show_help
      exit 1
      ;;
  esac
}

main "$@"
