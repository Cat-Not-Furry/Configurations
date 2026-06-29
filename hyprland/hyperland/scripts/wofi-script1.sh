#!/bin/bash
# wofi-script1.sh - Launcher con wofi para Hyprland
# Ubicación: ~/.config/hypr/scripts/wofi-script1.sh

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib/wofi-common.sh
source "$SCRIPT_DIR/lib/wofi-common.sh"

# Función para mostrar un submenú y ejecutar una acción (wofi_dmenu = misma estética que Super+D)

show_2k() {
  selected=$(echo -e "Normal\nPlus\nMagic Plus\n Volver" | wofi_dmenu --prompt "Selecciona el KOF 2002")

  case "$selected" in
  "Normal")
    notify-send -t 1000 -i "$HOME/.icons/kof2002-image.jpg" "The King of Figthers 2002" "Ejecutando...\nBOOTLEG EDITION"
    mame kof2002
    ;;
  "Plus")
    notify-send -t 1000 -i "$HOME/.icons/kof2002-image.jpg" "The King of Figthers 2002" "Ejecutando...\nPLUCERDA EDITION"
    mame kf2k2pls
    ;;
  "Magic Plus")
    notify-send -t 1000 -i "$HOME/.icons/kof2002-image.jpg" "The King of Figthers 2002" "Ejecutando...\nLA MAGICA PLUCERDA EDITION"
    mame kf2k2mp2
    ;;
  " Volver")
    show_kof
    ;;
  *)
    exit 1
    ;;
  esac
}

show_kof() {
  selected=$(echo -e "KOF98\nKOF2000\nKOF2002\n Volver" | wofi_dmenu --prompt "Seleccione el juego")

  case "$selected" in
  "KOF98")
    notify-send -t 1000 -i "$HOME/.icons/kof98-image.jpg" "The King of Figthers 1998" "EJECUTANDO........"
    mame kof98
    ;;
  "KOF2000")
    notify-send -t 1000 -i "$HOME/.icons/kof2000-image.jpg" "The King of Figthers 2000" "EJECUTANDO........"
    mame kof2000
    ;;
  "KOF2002")
    show_2k
    ;;
  " Volver")
    show_games
    ;;
  *)
    exit 1
    ;;
  esac
}

show_games() {
  selected=$(echo -e " KOF\n \n Garou\nProject-Brutality\n Volver" | wofi_dmenu --prompt "Seleccione el juego")

  case "$selected" in
  " KOF")
    show_kof
    ;;
  " ")
    notify-send -t 1000 -i "$HOME/.icons/mslug-image.jpg" "Metal Slug" "EJECUTANDO......."
    mame mslug
    ;;
  " Garou")
    notify-send -t 1000 -i "$HOME/.icons/garou-image.jpg" "Garou Mark of the Wolfs" "EJECUTANDO........"
    mame garou
    ;;
  "Project-Brutality")
    # notify-send -t 2000 -i "$HOME/.icons/project.jpg" "Project-Brutality" "EJECUTANDO......."
    ~/.config/gzdoom/pb-auto.sh
    ;;
  " Volver")
    # Ajusta esta llamada según tu configuración
    ~/.config/hypr/scripts/wofi-script1.sh
    ;;
  *)
    exit 1
    ;;
  esac
}

monitores() {
  selected=$(echo -e "Solo Portatil\nExtender\nDuplicar\nSolo Externa\n Volver" | wofi_dmenu --prompt "¿Que modo?")

  case "$selected" in
  "Solo Portatil")
    # Asegúrate de que 'monitor' esté en el PATH o usa ruta completa
    monitor-wofi p
    ;;
  "Extender")
    monitor-wofi ex
    ;;
  "Duplicar")
    monitor-wofi d
    ;;
  "Solo Externa")
    monitor-wofi s
    ;;
  " Volver")
    show_fondo
    ;;
  *)
    exit 1
    ;;
  esac
}

show_fondo() {
  selected=$(echo -e " Fondo\n󰹑 Monitores\n Volver" | wofi_dmenu --prompt "¿Que composicion?")

  case "$selected" in
  " Fondo")
    ~/.config/hypr/scripts/wofi_wallpaper.sh
    ;;
  "󰹑 Monitores")
    monitores
    ;;
  " Volver")
    show_tools
    ;;
  *)
    exit 1
    ;;
  esac
}

show_tools() {
  selected=$(echo -e " TaskManager\n󰹫 Pantallas\n󱄡 Audio-control\n Volver" | wofi_dmenu --prompt "Utilidades")

  case "$selected" in
  " TaskManager")
    xfce4-taskmanager
    ;;
  "󰹫 Pantallas")
    show_fondo
    ;;
  "󱄡 Audio-control")
    pavucontrol
    ;;
  " Volver")
    ~/.config/hypr/scripts/wofi-script1.sh
    ;;
  *)
    exit 1
    ;;
  esac
}

show_office() {
  selected=$(echo -e "󰎞 Texto\n Calculo\n󰛺 Presentaciones\n󰯁 Dibujo\n󰨣 Base de datos\n󰿉 Formulas\n Volver" | wofi_dmenu --prompt "¿Que hoja deseas utilzar?")

  case "$selected" in
  "󰎞 Texto")
    lowriter
    ;;
  " Calculo")
    localc
    ;;
  "󰛺 Presentaciones")
    loimpress
    ;;
  "󰯁 Dibujo")
    lodraw
    ;;
  "󰨣 Base de datos")
    lobase
    ;;
  "󰿉 Formulas")
    lomath
    ;;
  " Volver")
    show_notes
    ;;
  *)
    exit 1
    ;;
  esac
}

show_notes() {
  selected=$(echo -e " Krita\n LibreSprite\n Geany\n󰂺 Office\n󱓧 Obsidian\n󰎞 Mousepad\n Volver" | wofi_dmenu --prompt "Editores de texto")

  case "$selected" in
  " Krita")
    krita
    ;;
  " LibreSprite")
    libresprite
    ;;
  " Geany")
    geany
    ;;
  "󰂺 Office")
    show_office
    ;;
  "󱓧 Obsidian")
    obsidian
    ;;
  "󰎞 Mousepad")
    mousepad
    ;;
  " Volver")
    show_apps
    ;;
  *)
    exit 1
    ;;
  esac
}

show_apps() {
  selected=$(echo -e " Brave\n󰎞 Editores\n Strawberry\n Thunar\n Volver" | wofi_dmenu --prompt "$1")

  case $selected in
  " Brave")
    brave
    ;;
  "󰎞 Editores")
    show_notes
    ;;
  " Strawberry")
    strawberry
    ;;
  " Thunar")
    thunar
    ;;
  "󰂺 Office")
    show_office
    ;;
  " Volver")
    ~/.config/hypr/scripts/wofi-script1.sh
    ;;
  *)
    exit 1
    ;;
  esac
}

# Menú principal
option=$(echo -e "󰀻 Aplicaciones\n Utilidades\n󰊴 Juegos\n󰈆 Salir" | wofi_dmenu --prompt "Menú principal")

case $option in
"󰀻 Aplicaciones")
  show_apps "$USER"
  ;;
" Utilidades")
  show_tools
  ;;
"󰊴 Juegos")
  show_games
  ;;
"󰈆 Salir" | "")
  exit 0
  ;;
*)
  exit 1
  ;;
esac
