#!/usr/bin/env bash
# Plantilla barra dwm: métricas cnf-info + media cnf-media (probar en VM).
set -euo pipefail

# Resumen HW (4 líneas ANSI) — foot, dmenu, etc.
cnf-info 2>/dev/null || true

# Media MPRIS (requiere cnf-media en PATH)
if command -v cnf-media >/dev/null 2>&1; then
  cnf-media --refresh 2>/dev/null || true
  cnf-media --widget main --cached 2>/dev/null | sed -n 's/.*"text": "\([^"]*\)".*/\1/p' || true
fi
