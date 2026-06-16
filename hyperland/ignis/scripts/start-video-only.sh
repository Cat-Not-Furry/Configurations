#!/usr/bin/env bash
set -euo pipefail

RECORDING_DIR="$HOME/Videos/IgnisRecordings"
PID_FILE="$HOME/.cache/ignis/recording.pid"
DATE_STR=$(date +"%Y%m%d_%H%M%S")
OUTPUT_FILE="$RECORDING_DIR/video_${DATE_STR}.mp4"

mkdir -p "$RECORDING_DIR"
mkdir -p "$(dirname "$PID_FILE")"

# Monitor enfocado (automático)
MONITOR=$(hyprctl monitors -j | jq -r '.[] | select(.focused == true) | .name')
if [ -z "$MONITOR" ]; then
    MONITOR=$(hyprctl monitors -j | jq -r '.[0].name')
fi

# wf-recorder: 60 fps, hardware encoding h264_vaapi, bitrate 32M
wf-recorder -o "$MONITOR" -f "$OUTPUT_FILE" -c h264_vaapi -r 60 -b 32M &
REC_PID=$!
echo "$REC_PID" > "$PID_FILE"
echo "video" > "$HOME/.cache/ignis/recording.type"

notify-send "Grabación iniciada (solo vídeo)" "Salida: $OUTPUT_FILE" -i media-record-symbolic
