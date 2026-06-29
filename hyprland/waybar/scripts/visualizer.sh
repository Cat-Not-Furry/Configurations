#!/bin/bash

# Verificar si cmus o strawberry está ejecutándose
if ! pgrep -x "cmus" >/dev/null && ! pgrep -x "strawberry" >/dev/null; then
  echo ""
  exit 0
fi

# Determinar qué reproductor está activo y obtener su estado
if pgrep -x "cmus" >/dev/null; then
  STATUS=$(cmus-remote -Q 2>/dev/null | grep "status" | cut -d ' ' -f 2)
elif pgrep -x "strawberry" >/dev/null; then
  STATUS=$(dbus-send --print-reply --dest=org.mpris.MediaPlayer2.strawberry /org/mpris/MediaPlayer2 org.freedesktop.DBus.Properties.Get string:org.mpris.MediaPlayer2.Player string:PlaybackStatus 2>/dev/null | grep -oP '"\K[^"]+' | head -1 | tr '[:upper:]' '[:lower:]')
fi

if [ "$STATUS" != "playing" ]; then
  echo ""
  exit 0
fi

# Crear configuración para cava
CONFIG_DIR="$HOME/.config/cava"
CONFIG_FILE="$CONFIG_DIR/config-waybar"

# Asegurarse de que el directorio existe
mkdir -p "$CONFIG_DIR"

# Crear configuración específica para Waybar
cat >"$CONFIG_FILE" <<'EOF'
[general]
bars = 8
autosens = 1
overshoot = 20
sensitivity = 100
framerate = 30
sleep_timer = 0

[input]
method = pulse
source = auto

[output]
method = raw
raw_target = /dev/stdout
bit_format = 8bit
data_format = binary
channels = mono
EOF

# Ejecutar cava y capturar una línea de salida
VISUALIZATION=$(timeout 0.3s cava -p "$CONFIG_FILE" 2>/dev/null | head -c 8 | od -t x1 -An | tr -d ' \n' | sed 's/../& /g')

# Si no se obtuvo visualización, crear una aleatoria
if [ -z "$VISUALIZATION" ] || [ "$VISUALIZATION" = " " ]; then
  # Generar barras aleatorias como fallback
  for i in {1..8}; do
    RANDOM_VAL=$((RANDOM % 8))
    case $RANDOM_VAL in
    0) echo -n "▁" ;;
    1) echo -n "▂" ;;
    2) echo -n "▃" ;;
    3) echo -n "▄" ;;
    4) echo -n "▅" ;;
    5) echo -n "▆" ;;
    6) echo -n "▇" ;;
    7) echo -n "█" ;;
    esac
  done
  echo ""
  exit 0
fi

# Procesar cada valor hexadecimal
echo "$VISUALIZATION" | awk '{
  for(i=1; i<=NF; i++) {
    val = strtonum("0x" $i);
    if (val < 15) printf "▁";
    else if (val < 30) printf "▂";
    else if (val < 45) printf "▃";
    else if (val < 60) printf "▄";
    else if (val < 75) printf "▅";
    else if (val < 90) printf "▆";
    else if (val < 105) printf "▇";
    else printf "█";
  }
  printf "\n";
}'
