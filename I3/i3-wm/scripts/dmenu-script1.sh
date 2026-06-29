#!/bin/bash

# Función para mostrar un submenú y ejecutar una acción

show_2k() {
  selected=$(echo -e "Normal\nPlus\nMagic Plus\n Volver" | dmenu -i -nf "#9a9a9a" -sb "#632700" -sf "#8a8a8a" -p "Selecciona el KOF 2002")

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
  selected=$(echo -e "KOF98\nKOF2000\nKOF2002\n Volver" | dmenu -i -nf "#8a8a8a" -sb "#632700" -sf "#8a8a8a" -p "Seleccione el juego")

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
  selected=$(echo -e " KOF\n \n Garou\nProject-Brutality\n Volver" | dmenu -i -nf "#8a8a8a" -sb "#0d9200" -sf "#000000" -p "Seleccione el juego") #\n󰬎󰬡󰬋󰬖󰬖󰬔

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
    dmenu-script1
    ;;
  *)
    exit 1
    ;;
  esac

}

theme() {
  selected=$(echo -e "Clasico\nIceberg\n Volver" | dmenu -i -nf "#8a8a8a" -sb "#0d9200" -sf "#000000" -p " Tema (ventanas + polybar)")
  case "$selected" in
  "Clasico")
    ~/.config/i3/scripts/apply-i3-theme.sh classic
    ;;
  "Iceberg")
    ~/.config/i3/scripts/apply-i3-theme.sh iceberg
    ;;
  " Volver")
    show_tools
    ;;
  *)
    exit 1
    ;;
  esac
}

hyperland() {
  local mode hint toggle_script
  toggle_script="${HOME}/.config/i3/scripts/toggle-status-bar.sh"
  [ -x "$toggle_script" ] || toggle_script="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/toggle-status-bar.sh"

  mode="$("$toggle_script" status 2>/dev/null || echo bumblebee)"
  hint="Actual: ${mode}"
  selected=$(echo -e " Polybar (probar)\n Bumblebee (i3bar)\n Alternar (${mode})\n Volver" | dmenu -i -nf "#8a8a8a" -sb "#0d9200" -sf "#000000" -p " Barra — ${hint}")

  case "$selected" in
  " Polybar (probar)")
    "$toggle_script" polybar
    ;;
  " Bumblebee (i3bar)")
    "$toggle_script" bumblebee
    ;;
  " Alternar ("*)
    "$toggle_script" toggle
    ;;
  " Volver")
    show_fondo
    ;;
  *)
    exit 1
    ;;
  esac
}

monitores() {
  selected=$(echo -e "Solo Portatil\nExtender\nDuplicar\nSolo Externa\n Volver" | dmenu -i -nf "#8a8a8a" -sb "#0d9200" -sf "#0d9200" -sf "#000000" -p "¿Que modo?")

  case "$selected" in
  "Solo Portatil")
    monitor p
    ;;
  "Extender")
    monitor ex
    ;;
  "Duplicar")
    monitor d
    ;;
  "Solo Externa")
    monitor s
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
  selected=$(echo -e " Fondo\n󰂶 Picom\n 󰂶 Ambos\n󰂷 Quitar Picom\n󰹑 Tema\n󰹑 Monitores\n Hyperland\n Volver" | dmenu -i -nf "#8a8a8a" -sb "#0d9200" -sf "#0d9200" -sf "#000000" -p "¿Que composicion?")

  case "$selected" in
  " Fondo")
    fondo f
    ;;
  "󰂶 Picom")
    fondo t
    ;;
  " 󰂶 Ambos")
    fondo a
    ;;
  "󰂷 Quitar Picom")
    fondo k
    ;;
  "󰹑 Tema")
    theme
    ;;
  "󰹑 Monitores")
    monitores
    ;;
  " Hyperland")
    hyperland
    ;;
  " Volver")
    show_tools
    ;;
  *)
    exit 1
    ;;
  esac

}

#show_widtgets() {
#  selected=$(echo -e "󰥔 Reloj\n Reloj2\n Volver" | dmenu -i -nf "#8a8a8a" -sb "#0d9200" -sf "#0d9200" -sf "#000000" -p " ")
#  case "$selected" in
#  "󰥔 Reloj")
#    reloj
#  ;;
#  " Reloj2")
#    reloj2
#  ;;
#  " Volver")
#    show_tools
#  ;;
#  *)
#    exit 1
#  ;;
#  esac
#}

show_tools() {
  selected=$(echo -e " TaskManager\n󰹫 Pantallas\n󱄡 Audio-control\n Volver" | dmenu -i -nf "#8a8a8a" -sb "#0fa600" -sf "#000000" -p "Utilidades") #\n DWMBAR

  case "$selected" in
  " TaskManager")
    xfce4-taskmanager
    ;;
    #  "󰜬 Widtgets")
    #    show_widtgets
    #    ;;
  "󰹫 Pantallas")
    show_fondo
    ;;
  "󱄡 Audio-control")
    pavucontrol
    ;;
  " Temas")
    theme
    ;;
    #  " DWMBAR")
    #    initdwm
    #    ;;
  " Volver")
    dmenu-script1
    ;;
  *)
    exit 1
    ;;
  esac

}

show_office() {
  selected=$(echo -e "󰎞 Texto\n Calculo\n󰛺 Presentaciones\n󰯁 Dibujo\n󰨣 Base de datos\n󰿉 Formulas\n Volver" | dmenu -i -nf "#8a8a8a" -sb "#0fa600" -sf "#000000" -p "¿Que hoja deseas utilzar?") #󰜬 Widtgets

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
  selected=$(echo -e " Krita\n LibreSprite\n Geany\n󰂺 Office\n󱓧 Obsidian\n󰎞 Mousepad\n Volver" | dmenu -i -nf "#8a8a8a" -sb "#0fa600" -sf "#000000" -p "Editores de texto")

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
  selected=$(echo -e " Brave\n󰎞 Editores\n Strawberry\n Thunar\n Volver" | dmenu -i -nf "#8a8a8a" -sb "#0d9200" -sf "#000000" -p "$1") #\n GitHub

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
    #  " GitHub")
    #    github-desktop
    #    ;;
  " Volver")
    dmenu-script1
    ;;
  *)
    exit 1
    ;;
  esac
}

# Menú principal
option=$(echo -e "󰀻 Aplicaciones\n Utilidades\n󰊴 Juegos\n󰈆 Salir" | dmenu -nf "#8a8a8a" -sb "#0fa600" -sf "#000000" -i -p "Menú principal")

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
