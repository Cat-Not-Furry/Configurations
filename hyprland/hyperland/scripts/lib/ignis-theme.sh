#!/usr/bin/env bash
# Recarga de tema Ignis: CSS en caliente vía ignis run-python; fallback restart.

reload_ignis_theme_hot() {
  if ! command -v ignis >/dev/null 2>&1; then
    return 1
  fi
  if ! pgrep -x ignis >/dev/null 2>&1; then
    return 1
  fi

  # Esperar a que user_options.json termine de escribirse en disco.
  sleep 0.3

  ignis run-python "
import json
from pathlib import Path

from ignis import DATA_DIR
from ignis.css_manager import CssManager
from user_options import user_options

opts_path = Path(DATA_DIR) / 'user_options.json'
cache_path = Path.home() / '.cache/ignis/active-theme.json'

# Memoria puede quedar en tema viejo; leer siempre del disco + cache.
if opts_path.is_file():
    user_options.load_from_file(str(opts_path), emit=False)

theme_id = None
if cache_path.is_file():
    try:
        theme_id = json.loads(cache_path.read_text()).get('active')
    except (json.JSONDecodeError, OSError):
        pass
if not theme_id:
    theme_id = user_options.theme.active

user_options.theme.active = theme_id
user_options.material.colors = {}
CssManager.get_default().reload_all_css()
"
}

restart_ignis_profile() {
  kill_service_once ignis
  ensure_service_running ignis ignis init
  echo "Ignis: reiniciado (fallback)"
}

apply_ignis_theme() {
  if reload_ignis_theme_hot; then
    echo "Ignis: CSS recargado en caliente"
    return 0
  fi

  echo "Ignis: hot reload no disponible; reiniciando..."
  restart_ignis_profile
}
