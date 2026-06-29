#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
if [ "$(bash "$SCRIPT_DIR/recording-status.sh")" != "none" ]; then
    notify-send "Grabación activa" "Detén la grabación actual primero" -i dialog-warning
    exit 1
fi

RECORDING_DIR="$HOME/Videos/IgnisRecordings"
PID_FILE="$HOME/.cache/ignis/recording.pid"
LOG_FILE="$HOME/.cache/ignis/recording.log"
DATE_STR=$(date +"%Y%m%d_%H%M%S")
OUTPUT_FILE="$RECORDING_DIR/audio_video_${DATE_STR}.mp4"

mkdir -p "$RECORDING_DIR"
mkdir -p "$(dirname "$PID_FILE")"

MONITOR=$(hyprctl monitors -j | jq -r '.[] | select(.focused == true) | .name')
if [ -z "$MONITOR" ]; then
    MONITOR=$(hyprctl monitors -j | jq -r '.[0].name')
fi

AUDIO_DEVICE="$(pactl get-default-sink).monitor"

wf-recorder -o "$MONITOR" -f "$OUTPUT_FILE" -a "$AUDIO_DEVICE" \
    -c h264_vaapi -r 60 -b 32M \
    >/dev/null 2>>"$LOG_FILE" &
REC_PID=$!
disown "$REC_PID" 2>/dev/null || true

sleep 0.3
if ! kill -0 "$REC_PID" 2>/dev/null; then
    notify-send "Error" "No se pudo iniciar la grabación. Ver $LOG_FILE" -i dialog-error
    exit 1
fi

echo "$REC_PID" > "$PID_FILE"
echo "audio" > "$HOME/.cache/ignis/recording.type"

notify-send "Grabación iniciada (vídeo + audio)" "Salida: $OUTPUT_FILE" -i media-record-symbolic
