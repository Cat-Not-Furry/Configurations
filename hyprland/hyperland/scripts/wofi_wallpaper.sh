#!/usr/bin/env bash

# ===================================================================================
# Gestor de fondos para Hyprland (Wofi + temas dinámicos vía wofi-common.sh)
#
# Herramientas: wofi, swww/awww-wallpaper, mpvpaper (AUR), find, shuf
# ===================================================================================

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib/wofi-common.sh
source "$SCRIPT_DIR/lib/wofi-common.sh"

STATIC_WALL_DIR="$HOME/.config/fondos/"
VIDEO_WALL_DIR="$HOME/Videos/"

opciones=$'Fondo Estático\nFondo Aleatorio\nFondo de Video'

eleccion=$(echo -e "$opciones" | wofi_dmenu --prompt "Gestor de Fondos")

case "$eleccion" in
$'Fondo Estático')
  seleccion=$(
    find "$STATIC_WALL_DIR" -type f \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" -o -iname "*.webp" \) |
      wofi_dmenu --prompt "Elige un fondo"
  )
  if [ -n "$seleccion" ]; then
    ~/.config/hypr/scripts/awww-wallpaper.sh "$seleccion" fade
  fi
  ;;
$'Fondo Aleatorio')
  fondo_aleatorio=$(
    find "$STATIC_WALL_DIR" -type f \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" -o -iname "*.webp" -o -iname "*.gif" \) |
      shuf -n 1
  )
  if [ -n "$fondo_aleatorio" ]; then
    ~/.config/hypr/scripts/awww-wallpaper.sh "$fondo_aleatorio" fade
  fi
  ;;
$'Fondo de Video')
  video_seleccionado=$(
    find "$VIDEO_WALL_DIR" -type f \( -iname "*.mp4" -o -iname "*.mkv" -o -iname "*.mov" -o -iname "*.webm" \) |
      wofi_dmenu --prompt "Elige un video"
  )
  if [ -n "$video_seleccionado" ]; then
    killall mpvpaper &>/dev/null
    sleep 0.5
    monitor=$(hyprctl monitors | grep 'Monitor' | awk '{print $2}')
    mpvpaper -p -o "loop" "$monitor" "$video_seleccionado"
  fi
  ;;
esac

exit 0
