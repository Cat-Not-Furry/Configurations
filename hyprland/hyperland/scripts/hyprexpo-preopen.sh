#!/usr/bin/env bash
# Cierra popups flotantes antes del overview (evita crash en renderSnapshot/CPopup).
set -euo pipefail

if command -v wtype >/dev/null 2>&1; then
  wtype -k Escape 2>/dev/null || true
fi
if command -v copyq >/dev/null 2>&1; then
  copyq hide 2>/dev/null || true
fi
sleep 0.08
