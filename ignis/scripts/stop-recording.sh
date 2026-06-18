#!/usr/bin/env bash
set -euo pipefail

PID_FILE="$HOME/.cache/ignis/recording.pid"

if [ -f "$PID_FILE" ]; then
    REC_PID=$(cat "$PID_FILE")
    if kill -0 "$REC_PID" 2>/dev/null; then
        # Enviar SIGINT para que ffmpeg/wf-recorder finalicen correctamente
        kill -2 "$REC_PID"
        sleep 1
        if kill -0 "$REC_PID" 2>/dev/null; then
            kill -9 "$REC_PID"
        fi
        rm -f "$PID_FILE"
        rm -f "$HOME/.cache/ignis/recording.type"
        notify-send "Grabación detenida" "El vídeo se ha guardado" -i media-playback-stop-symbolic
    else
        rm -f "$PID_FILE"
        rm -f "$HOME/.cache/ignis/recording.type"
        notify-send "Error" "No hay una grabación activa" -i dialog-error
    fi
else
    notify-send "Error" "No se encontró archivo PID" -i dialog-error
fi
