#!/usr/bin/env python3
"""
Waybar custom module for media control (playerctl)
Port from bumblebee-status media.py
"""

import argparse
import html
import json
import subprocess
import sys

DEFAULT_PLAYER = None
DEFAULT_VOLUME_STEP = 0.05
DEFAULT_FORMAT = "{state} {artist} - {title}"
MAX_ARTIST_LEN = 30
MAX_TITLE_LEN = 30
DEFAULT_ICONS = {
    "prev": "⏮",
    "next": "⏭",
    "play": "▶",
    "pause": "⏸",
    "stop": "⏹",
}

IGNORE_PLAYERS = ("spotify",)


def player_name(player: str) -> str:
    return player.lower()


def is_ignored_player(player: str) -> bool:
    name = player_name(player)
    return any(ignored in name for ignored in IGNORE_PLAYERS)

def execute_playerctl(cmd, player=None):
    """Run a playerctl command and return its output."""
    base = ["playerctl"]
    if player:
        base += ["-p", player]
    full_cmd = base + cmd
    try:
        result = subprocess.run(full_cmd, capture_output=True, text=True)
        if result.returncode != 0:
            return None
        return result.stdout.strip()
    except FileNotFoundError:
        return None

def list_players():
    try:
        result = subprocess.run(
            ["playerctl", "-l"],
            capture_output=True,
            text=True,
        )
        if result.returncode != 0:
            return []
        return [p.strip() for p in result.stdout.splitlines() if p.strip()]
    except FileNotFoundError:
        return []

def get_status(player=None):
    """Return status string: Playing, Paused, Stopped, or None."""
    return execute_playerctl(["status"], player)

def resolve_player(explicit=None):
    if explicit:
        return explicit
    players = [p for p in list_players() if not is_ignored_player(p)]
    if not players:
        return None
    if len(players) == 1:
        return players[0]
    for status in ("Playing", "Paused", "Stopped"):
        for candidate in players:
            if get_status(candidate) == status:
                return candidate
    return players[0]


def run_playerctl(player, cmd):
    if not player:
        return False
    try:
        result = subprocess.run(
            ["playerctl", "-p", player] + cmd,
            capture_output=True,
            text=True,
        )
        return result.returncode == 0
    except FileNotFoundError:
        return False


def toggle_playback(player):
    """Pause/Play explícito: PlayPause en navegadores puede ir a Stop."""
    status = get_status(player)
    if status == "Playing":
        return run_playerctl(player, ["pause"])
    if status == "Paused":
        return run_playerctl(player, ["play"])
    if status == "Stopped":
        return run_playerctl(player, ["play"])
    return False

def get_metadata(player=None):
    """Return (artist, title) tuple, empty strings if missing."""
    meta = execute_playerctl(["metadata", "-f", "{{artist}}|||{{title}}"], player)
    if meta:
        parts = meta.split("|||", 1)
        artist = parts[0] if parts else ""
        title = parts[1] if len(parts) > 1 else ""
        return artist, title
    return "", ""

def escape_markup(text: str) -> str:
    """GTK/Pango trata el label como markup: &, <, > deben escaparse."""
    return html.escape(text or "", quote=False)

def truncate(text: str, max_len: int) -> str:
    text = (text or "").strip()
    if len(text) <= max_len:
        return text
    if max_len <= 3:
        return text[:max_len]
    return text[: max_len - 3] + "..."

def state_icon(status, icons):
    """Return icon for given status."""
    return {
        "Playing": icons["play"],
        "Paused": icons["pause"],
        "Stopped": icons["stop"],
    }.get(status, "?")

def main():
    parser = argparse.ArgumentParser(description="Waybar media module using playerctl")
    parser.add_argument("--widget", choices=["prev", "main", "next"], help="Which widget to display")
    parser.add_argument("--player", default=DEFAULT_PLAYER, help="Player name (for playerctl -p)")
    parser.add_argument("--volume-step", type=float, default=DEFAULT_VOLUME_STEP)
    parser.add_argument("--format", default=DEFAULT_FORMAT)
    parser.add_argument("--icon-prev", default=DEFAULT_ICONS["prev"])
    parser.add_argument("--icon-next", default=DEFAULT_ICONS["next"])
    parser.add_argument("--icon-play", default=DEFAULT_ICONS["play"])
    parser.add_argument("--icon-pause", default=DEFAULT_ICONS["pause"])
    parser.add_argument("--icon-stop", default=DEFAULT_ICONS["stop"])

    # Acciones (para los clicks)
    parser.add_argument("--prev", action="store_true", help="Previous track")
    parser.add_argument("--next", action="store_true", help="Next track")
    parser.add_argument("--play-pause", action="store_true", help="Play/pause")
    parser.add_argument("--vol-up", action="store_true", help="Increase volume")
    parser.add_argument("--vol-down", action="store_true", help="Decrease volume")

    args = parser.parse_args()

    player = resolve_player(args.player)

    icons = {
        "prev": args.icon_prev,
        "next": args.icon_next,
        "play": args.icon_play,
        "pause": args.icon_pause,
        "stop": args.icon_stop,
    }

    # Ejecutar acciones y salir
    if args.prev:
        if player:
            run_playerctl(player, ["previous"])
        return
    if args.next:
        if player:
            run_playerctl(player, ["next"])
        return
    if args.play_pause:
        toggle_playback(player)
        return
    if args.vol_up:
        if player:
            run_playerctl(player, ["volume", f"{args.volume_step}+"])
        return
    if args.vol_down:
        if player:
            run_playerctl(player, ["volume", f"{args.volume_step}-"])
        return

    # Si no hay acción, mostrar widget según --widget
    if not args.widget:
        parser.print_help()
        sys.exit(1)

    status = get_status(player)
    if status is None:
        # Sin reproductor activo → widget vacío (se oculta en Waybar)
        if args.widget == "main":
            print(json.dumps({"text": "", "class": "stopped", "tooltip": "No player active"}))
        else:
            print(json.dumps({"text": "", "class": "hidden"}))
        return

    if args.widget in ("prev", "next"):
        icon = icons["prev"] if args.widget == "prev" else icons["next"]
        print(json.dumps({"text": icon, "class": args.widget}))
        return

    # Widget principal
    artist, title = get_metadata(player)
    artist = escape_markup(artist)
    title = escape_markup(title)
    state_icon_str = state_icon(status, icons)
    artist_s = truncate(artist, MAX_ARTIST_LEN)
    title_s = truncate(title, MAX_TITLE_LEN)
    if artist_s and title_s:
        text = f"{state_icon_str} {artist_s} - {title_s}"
    elif artist_s:
        text = f"{state_icon_str} {artist_s}"
    elif title_s:
        text = f"{state_icon_str} {title_s}"
    else:
        text = state_icon_str
    tooltip = f"{artist} - {title}" if artist or title else status
    class_name = status.lower()  # "playing", "paused", "stopped"

    output = {
        "text": text,
        "tooltip": tooltip,
        "class": class_name,
    }
    print(json.dumps(output))

if __name__ == "__main__":
    main()
