#!/bin/bash

# ===================================================================================
# Script de Wallpapers para Hyprland con Wofi
#
# Herramientas requeridas:
# wofi, swww, mpvpaper (del AUR), find, shuf
# ===================================================================================

# --- CONFIGURACIÓN ---
# Define los directorios donde guardas tus fondos de pantalla.
# CAMBIA ESTAS RUTAS para que apunten a tus carpetas.
STATIC_WALL_DIR="$HOME/.config/i3/fondos/"
VIDEO_WALL_DIR="$HOME/Videos/"

# --- LÓGICA DEL SCRIPT ---

# Opciones del menú principal de Wofi
opciones=" Fondo Estático\n🎲 Fondo Aleatorio\n🎬 Fondo de Video"

# Mostrar el menú principal y capturar la elección del usuario
eleccion=$(echo -e "$opciones" | wofi --dmenu --prompt "Gestor de Fondos")

# Ejecutar la acción basada en la elección
case $eleccion in
" Fondo Estático")
  # Buscar imágenes (png, jpg, jpeg, webp) de forma recursiva en el directorio
  seleccion=$(find "$STATIC_WALL_DIR" -type f \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" -o -iname "*.webp" \) | wofi --dmenu --prompt "Elige un fondo")

  # Si el usuario seleccionó un archivo, establecerlo como fondo con swww
  if [ -n "$seleccion" ]; then
    swww img "$seleccion" --transition-type random
    swww img "$seleccion" --transition-type random --outputs HDMI-A-2

  fi
  ;;

"🎲 Fondo Aleatorio")
  # Buscar todas las imágenes y seleccionar una al azar
  fondo_aleatorio=$(find "$STATIC_WALL_DIR" -type f \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" -o -iname "*.webp" -o -iname "*.gif" \) | shuf -n 1)

  # Si se encontró un fondo, establecerlo
  if [ -n "$fondo_aleatorio" ]; then
    swww img "$fondo_aleatorio" --transition-type random
    swww img "$fondo_aleatorio" --transition-type random --outputs HDMI-A-2

  fi
  ;;

"🎬 Fondo de Video")
  # Buscar videos (mp4, mkv, mov, webm)
  video_seleccionado=$(find "$VIDEO_WALL_DIR" -type f \( -iname "*.mp4" -o -iname "*.mkv" -o -iname "*.mov" -o -iname "*.webm" \) | wofi --dmenu --prompt "Elige un video")

  # Si se seleccionó un video...
  if [ -n "$video_seleccionado" ]; then
    # Matar cualquier instancia previa de mpvpaper para evitar superposiciones
    killall mpvpaper &>/dev/null
    sleep 0.5 # Dar un respiro para que el proceso muera

    # Obtener el nombre del monitor activo
    monitor=$(hyprctl monitors | grep 'Monitor' | awk '{print $2}')

    # Iniciar el nuevo fondo de video
    mpvpaper -p -o "loop" "$monitor" "$video_seleccionado"
  fi
  ;;
esac

exit 0
