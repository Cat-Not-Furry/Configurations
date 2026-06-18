"""Carga paletas de tema desde themes/palettes.json."""

from __future__ import annotations

import json
import os
from pathlib import Path

from ignis import DATA_DIR, utils

_CACHE_FILE = Path(os.path.expanduser("~/.cache/ignis/active-theme.json"))


def _palettes_paths() -> list[Path]:
    base = Path(utils.get_current_dir())
    return [
        Path(DATA_DIR) / "themes" / "palettes.json",
        base / "themes" / "palettes.json",
        base.parent / "themes" / "palettes.json",
    ]


def find_palettes_file() -> Path | None:
    for path in _palettes_paths():
        if path.is_file():
            return path
    return None


def load_palettes() -> dict:
    path = find_palettes_file()
    if not path:
        return {}
    with open(path) as f:
        return json.load(f)


def get_active_theme_id(user_options) -> str:
    active = getattr(getattr(user_options, "theme", None), "active", None)
    if active:
        return active
    if _CACHE_FILE.is_file():
        try:
            with open(_CACHE_FILE) as f:
                return json.load(f).get("active", "blue")
        except (json.JSONDecodeError, OSError):
            pass
    data = load_palettes()
    return data.get("default", "blue")


def get_theme_ignis_colors(user_options) -> dict[str, str] | None:
    if user_options.material.colors:
        return None

    data = load_palettes()
    if not data:
        return None

    theme_id = get_active_theme_id(user_options)
    theme = data.get("themes", {}).get(theme_id)
    if not theme:
        return None

    ignis_colors = theme.get("ignis", {})
    return ignis_colors if ignis_colors else None


def get_theme_label(theme_id: str | None = None, user_options=None) -> str:
    data = load_palettes()
    if not data:
        return theme_id or "Tema"
    if theme_id is None and user_options is not None:
        theme_id = get_active_theme_id(user_options)
    theme_id = theme_id or data.get("default", "blue")
    return data.get("themes", {}).get(theme_id, {}).get("label", theme_id)


def get_next_theme_id(current_id: str) -> str:
    data = load_palettes()
    order = data.get("order", ["blue", "green", "red"])
    if current_id not in order:
        return order[0] if order else "blue"
    idx = order.index(current_id)
    return order[(idx + 1) % len(order)]


def get_hover_hint_ms() -> int:
    data = load_palettes()
    return int(data.get("hover_hint_ms", 1000))
