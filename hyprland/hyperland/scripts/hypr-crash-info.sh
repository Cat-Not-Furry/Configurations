#!/usr/bin/env bash
# Muestra el log de Hyprland más reciente y reportes de crash.
set -euo pipefail

RUNTIME="${XDG_RUNTIME_DIR:-/run/user/$(id -u)}"
HYPR_DIR="${RUNTIME}/hypr"
CACHE="${XDG_CACHE_HOME:-$HOME/.cache}/hyprland"

echo "=== Sesiones Hyprland (${HYPR_DIR}) ==="
if [ -d "$HYPR_DIR" ]; then
  ls -lt "$HYPR_DIR" 2>/dev/null | head -8 || true
else
  echo "(no existe $HYPR_DIR)"
fi

echo
echo "=== hyprland.log (sesión más reciente, últimas 80 líneas) ==="
if [ -d "$HYPR_DIR" ]; then
  latest="$(ls -t "$HYPR_DIR" 2>/dev/null | head -n 1)"
  if [ -n "$latest" ] && [ -f "$HYPR_DIR/$latest/hyprland.log" ]; then
    echo "Archivo: $HYPR_DIR/$latest/hyprland.log"
    tail -n 80 "$HYPR_DIR/$latest/hyprland.log"
  else
    echo "Sin hyprland.log"
  fi
else
  echo "Hyprland no en ejecución o sin runtime dir"
fi

echo
echo "=== Crash reports (${CACHE}) ==="
if compgen -G "${CACHE}/hyprlandCrashReport"*.txt >/dev/null 2>&1; then
  ls -lt "${CACHE}"/hyprlandCrashReport*.txt 2>/dev/null | head -5
  newest="$(ls -t "${CACHE}"/hyprlandCrashReport*.txt 2>/dev/null | head -n 1)"
  echo "--- $newest (últimas 40 líneas) ---"
  tail -n 40 "$newest"
else
  echo "(ninguno)"
fi

echo
echo "=== Deploy log ==="
deploy_log="${XDG_CACHE_HOME:-$HOME/.cache}/hypr/deploy.log"
if [ -f "$deploy_log" ]; then
  echo "Archivo: $deploy_log"
  tail -n 40 "$deploy_log"
else
  echo "(no existe $deploy_log)"
fi

echo
echo "=== hyprctl configerrors ==="
hyprctl configerrors 2>/dev/null || echo "(hyprctl no disponible)"
