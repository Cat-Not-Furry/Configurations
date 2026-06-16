#!/usr/bin/env bash
set -euo pipefail

RECORDING_DIR="$HOME/Videos/IgnisRecordings"
PID_FILE="$HOME/.cache/ignis/recording.pid"
DATE_STR=$(date +"%Y%m%d_%H%M%S")
OUTPUT_FILE="$RECORDING_DIR/audio_video_${DATE_STR}.mp4"

mkdir -p "$RECORDING_DIR"
mkdir -p "$(dirname "$PID_FILE")"

# Encontrar automáticamente el dispositivo DRM (card0 o card1)
DRM_DEVICE=$(find /dev/dri -name "card*" 2>/dev/null | head -n 1)
if [ -z "$DRM_DEVICE" ]; then
    notify-send "Error ffmpeg" "No se encontró dispositivo DRM" -i dialog-error
    exit 1
fi

# Sink de audio por defecto
AUDIO_SINK="$(pactl get-default-sink).monitor"

# ffmpeg con kmsgrab automático, sin necesidad de -low_power 0 (se infiere)
ffmpeg -framerate 60 -f kmsgrab -i "$DRM_DEVICE" \
       -f pulse -i "$AUDIO_SINK" \
       -vf 'hwmap=derive_device=vaapi,scale_vaapi=w=1920:h=1080' \
       -c:v h264_vaapi -qp 32 \
       -c:a aac -b:a 128k \
       "$OUTPUT_FILE" &

REC_PID=$!
echo "$REC_PID" > "$PID_FILE"
echo "audio" > "$HOME/.cache/ignis/recording.type"

notify-send "Grabación iniciada (vídeo + audio)" "Salida: $OUTPUT_FILE" -i media-record-symbolic
