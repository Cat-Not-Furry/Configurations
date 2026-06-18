"""Lee la posición de Waybar (top/bottom) desde caché o user_options."""

from __future__ import annotations

import json
from pathlib import Path

from user_options import user_options

STATE_FILE = Path.home() / ".cache/hypr/waybar-position.json"


def read_cached_bar_position() -> str | None:
    if not STATE_FILE.is_file():
        return None
    try:
        with open(STATE_FILE) as f:
            pos = json.load(f).get("position")
            if pos in ("top", "bottom"):
                return pos
    except (json.JSONDecodeError, OSError):
        pass
    return None


def get_bar_position() -> str:
    cached = read_cached_bar_position()
    if cached:
        return cached
    pos = getattr(getattr(user_options, "bar", None), "position", None)
    if pos in ("top", "bottom"):
        return pos
    return "top"


def get_bar_height() -> int:
    height = getattr(getattr(user_options, "bar", None), "height", None)
    if isinstance(height, int) and height > 0:
        return height
    return 26


def bar_margin_offset() -> int:
    """Margen extra para widgets anclados al borde opuesto a Waybar."""
    return get_bar_height() + 8
