"""Paleta CopyQ: colores nativos (bg/fg/sel_bg) desde palettes.json."""

from __future__ import annotations

import re
from pathlib import Path

# Gris neutro exclusivo de CopyQ — no aparece en palettes.json
SEL_BG = "#6E6E6E"
SEL_FG = "#000000"
_LUM_THRESHOLD = 0.42

_COLOR_KEYS = (
    "bg",
    "fg",
    "sel_bg",
    "sel_fg",
    "alt_bg",
    "edit_bg",
    "edit_fg",
    "find_bg",
    "find_fg",
    "notes_bg",
    "notes_fg",
    "notification_bg",
    "notification_fg",
)

_WAYBAR_LIGHT_KEYS = (
    "accent_light",
    "media_playing",
    "media_paused",
    "warning",
    "accent",
    "border",
    "urgent",
    "critical",
    "foreground",
)

_IGNIS_LIGHT_KEYS = (
    "onPrimaryContainer",
    "onSecondaryContainer",
    "onTertiaryContainer",
    "onSurfaceVariant",
    "inverseSurface",
    "secondary_paletteKeyColor",
    "tertiary_paletteKeyColor",
    "onBackground",
    "onSurface",
)


def _parse_hex(color: str) -> tuple[int, int, int]:
    color = color.strip()
    if not color.startswith("#"):
        color = f"#{color}"
    hex_part = color[1:]
    if len(hex_part) == 8:
        hex_part = hex_part[2:]
    if len(hex_part) != 6 or not re.fullmatch(r"[0-9a-fA-F]{6}", hex_part):
        raise ValueError(f"Color inválido: {color}")
    return (
        int(hex_part[0:2], 16),
        int(hex_part[2:4], 16),
        int(hex_part[4:6], 16),
    )


def _normalize_hex(color: str) -> str:
    r, g, b = _parse_hex(color)
    return f"#{r:02x}{g:02x}{b:02x}".upper()


def _relative_luminance(color: str) -> float:
    r, g, b = _parse_hex(color)

    def channel(c: int) -> float:
        x = c / 255.0
        return x / 12.92 if x <= 0.03928 else ((x + 0.055) / 1.055) ** 2.4

    return 0.2126 * channel(r) + 0.7152 * channel(g) + 0.0722 * channel(b)


def is_light_color(color: str, threshold: float = _LUM_THRESHOLD) -> bool:
    try:
        return _relative_luminance(color) >= threshold
    except ValueError:
        return False


def _collect_light_colors(waybar: dict, ignis: dict) -> list[str]:
    seen: set[str] = set()
    pool: list[str] = []

    def add(value: str | None) -> None:
        if not value:
            return
        try:
            normalized = _normalize_hex(value)
        except ValueError:
            return
        if not is_light_color(normalized):
            return
        key = normalized.lower()
        if key in seen:
            return
        seen.add(key)
        pool.append(normalized)

    for name in _WAYBAR_LIGHT_KEYS:
        add(waybar.get(name))
    for name in _IGNIS_LIGHT_KEYS:
        add(ignis.get(name))

    return pool


def _pick(pool: list[str], index: int, fallback: str) -> str:
    if not pool:
        return _normalize_hex(fallback)
    return pool[min(index, len(pool) - 1)]


def _pick_highlight(pool: list[str], surface: str, fg: str) -> str:
    skip = {surface.lower(), fg.lower()}
    for color in pool:
        if color.lower() not in skip:
            return color
    return surface


def resolve_copyq_slug(theme_id: str, theme: dict) -> str:
    """Slug del archivo themes/{slug}.ini (campo copyq en palettes.json)."""
    return theme.get("copyq") or theme.get("cava") or theme_id.replace("_", "-")


def build_copyq_theme(theme: dict) -> dict[str, str]:
    """Colores CopyQ nativos: base oscura + selección fija gris/negro."""
    waybar = theme.get("waybar", {})
    ignis = theme.get("ignis", {})

    bg = _normalize_hex(waybar.get("background", "#161821"))
    fg_raw = waybar.get("foreground", "#FFFFFF")
    fg = _normalize_hex(fg_raw) if is_light_color(fg_raw) else "#FFFFFF"

    pool = _collect_light_colors(waybar, ignis)
    surface = _pick(pool, 0, "#A2B9D6")
    highlight = _pick_highlight(pool, surface, fg)

    return {
        "bg": bg,
        "fg": fg,
        "sel_bg": SEL_BG,
        "sel_fg": SEL_FG,
        "alt_bg": surface,
        "edit_bg": surface,
        "edit_fg": fg,
        "find_bg": surface,
        "find_fg": fg,
        "notes_bg": surface,
        "notes_fg": fg,
        "notification_bg": highlight,
        "notification_fg": fg,
    }


def _theme_layout_lines() -> list[str]:
    """Plantilla [General] compatible con CopyQ (claves nativas + CSS)."""
    return [
        "css_template_items=items",
        "css_template_main_window=main_window",
        "css_template_menu=menu",
        "css_template_notification=notification",
        "style_main_window=false",
        "show_number=true",
        "show_scrollbars=true",
        'font="Noto Sans,12,-1,5,400,0,0,0,0,0,0,0,0,0,0,1,Regular"',
        "font_antialiasing=true",
        "use_system_icons=false",
        "icon_size=16",
        "num_margin=2",
        "num_fg=default_placeholder_text",
        "css=",
        'cur_item_css="\\n    ;border: 0.1em solid ${sel_bg}"',
        'menu_bar_css="\\n    ;background: ${bg}\\n    ;color: ${fg}"',
        'menu_bar_disabled_css="\\n    ;color: ${bg - #666}"',
        'menu_bar_selected_css="\\n    ;background: ${sel_bg}\\n    ;color: ${sel_fg}"',
        'menu_css="\\n    ;border: 1px solid ${sel_bg}\\n    ;background: ${bg}\\n    ;color: ${fg}"',
        'search_bar="\\n    ;background: ${edit_bg}\\n    ;color: ${edit_fg}\\n    ;border: 1px solid ${alt_bg}\\n    ;margin: 2px"',
        'search_bar_focused="\\n    ;border: 1px solid ${sel_bg}"',
        'tab_bar_css="\\n    ;background: ${bg - #222}"',
        'tab_bar_item_counter="\\n    ;color: ${fg - #044 + #400}\\n    ;font-size: 6pt"',
        'tab_bar_scroll_buttons_css="\\n    ;background: ${bg - #222}\\n    ;color: ${fg}\\n    ;border: 0"',
        'tab_bar_sel_item_counter="\\n    ;color: ${sel_bg - #044 + #400}"',
        'tab_bar_tab_selected_css="\\n    ;padding: 0.5em\\n    ;background: ${bg}\\n    ;border: 0.05em solid ${bg}\\n    ;color: ${fg}"',
        'tab_bar_tab_unselected_css="\\n    ;border: 0.05em solid ${bg}\\n    ;padding: 0.5em\\n    ;background: ${bg - #222}\\n    ;color: ${fg - #333}"',
        'tab_tree_css="\\n    ;color: ${fg}\\n    ;background-color: ${bg}"',
        'tab_tree_item_counter="\\n    ;color: ${fg - #044 + #400}\\n    ;font-size: 6pt"',
        'tab_tree_sel_item_counter="\\n    ;color: ${sel_fg - #044 + #400}"',
        'tab_tree_sel_item_css="\\n    ;color: ${sel_fg}\\n    ;background-color: ${sel_bg}\\n    ;border-radius: 2px"',
        'tool_bar_css="\\n    ;color: ${fg}\\n    ;background-color: ${bg}\\n    ;border: 0"',
        'tool_button_css="\\n    ;color: ${fg}\\n    ;background: ${bg}\\n    ;border: 0\\n    ;border-radius: 2px"',
        'tool_button_pressed_css="\\n    ;background: ${sel_bg}"',
        'tool_button_selected_css="\\n    ;background: ${sel_bg - #222}\\n    ;color: ${sel_fg}\\n    ;border: 1px solid ${sel_bg}"',
    ]


def format_ini(theme_label: str, colors: dict[str, str]) -> str:
    """Genera themes/{slug}.ini en formato nativo CopyQ ([General])."""
    lines = [f"# Tema: {theme_label}", "[General]"]
    lines.extend(_theme_layout_lines())
    for key in _COLOR_KEYS:
        if key in colors:
            lines.append(f"{key}={colors[key]}")
    return "\n".join(lines) + "\n"


def _set_ini_key(text: str, key: str, value: str) -> str:
    pattern = rf"^{re.escape(key)}=.*$"
    replacement = f"{key}={value}"
    if re.search(pattern, text, flags=re.MULTILINE):
        return re.sub(pattern, replacement, text, count=1, flags=re.MULTILINE)
    theme_match = re.search(r"^\[Theme\]\s*$", text, flags=re.MULTILINE)
    if theme_match:
        insert_at = theme_match.end()
        return text[:insert_at] + f"\n{replacement}" + text[insert_at:]
    return text + f"\n{replacement}\n"


def patch_copyq_conf(conf_path: Path, colors: dict[str, str], slug: str) -> None:
    """Actualiza style= y colores en [Theme] de copyq.conf (CopyQ lee esto al arrancar)."""
    text = conf_path.read_text(encoding="utf-8")
    text = re.sub(r"^style=.*$", f"style={slug}", text, count=1, flags=re.MULTILINE)
    for key in _COLOR_KEYS:
        if key in colors:
            text = _set_ini_key(text, key, colors[key])
    conf_path.write_text(text, encoding="utf-8")
