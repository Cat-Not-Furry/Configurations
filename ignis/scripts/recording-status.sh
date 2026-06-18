#!/bin/bash
# Devuelve: "none", "video" o "audio"
PID_FILE="$HOME/.cache/ignis/recording.pid"
if [ -f "$PID_FILE" ]; then
    REC_PID=$(cat "$PID_FILE")
    if kill -0 "$REC_PID" 2>/dev/null; then
        # Determinar tipo de grabación (lo guardaremos en otro archivo)
        TYPE_FILE="$HOME/.cache/ignis/recording.type"
        if [ -f "$TYPE_FILE" ]; then
            cat "$TYPE_FILE"
        else
            echo "unknown"
        fi
    else
        rm -f "$PID_FILE" "$HOME/.cache/ignis/recording.type"
        echo "none"
    fi
else
    echo "none"
fi
