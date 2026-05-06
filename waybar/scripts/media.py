#!/usr/bin/env python3
"""
Waybar custom module for media control (playerctl)
Port from bumblebee-status media.py
"""

import argparse
import json
import subprocess
import sys
from collections import defaultdict

DEFAULT_PLAYER = None
DEFAULT_VOLUME_STEP = 0.05
DEFAULT_FORMAT = "{state} {artist} - {title}"
DEFAULT_ICONS = {
    "prev": "⏮",
    "next": "⏭",
    "play": "▶",
    "pause": "⏸",
    "stop": "⏹",
}

def execute_playerctl(cmd, player=None):
    """Run a playerctl command and return its output."""
    base = ["playerctl"]
    if player:
        base += ["-p", player]
    full_cmd = base + cmd
    try:
        result = subprocess.run(full_cmd, capture_output=True, text=True, check=True)
        return result.stdout.strip()
    except (subprocess.CalledProcessError, FileNotFoundError):
        return None

def get_status(player=None):
    """Return status string: Playing, Paused, Stopped, or None."""
    return execute_playerctl(["status"], player)

def get_metadata(player=None):
    """Return (artist, title) tuple, empty strings if missing."""
    meta = execute_playerctl(["metadata", "-f", "{{artist}}|||{{title}}"], player)
    if meta:
        parts = meta.split("|||", 1)
        artist = parts[0] if parts else ""
        title = parts[1] if len(parts) > 1 else ""
        return artist, title
    return "", ""

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

    icons = {
        "prev": args.icon_prev,
        "next": args.icon_next,
        "play": args.icon_play,
        "pause": args.icon_pause,
        "stop": args.icon_stop,
    }

    # Construir comando base de playerctl (con -p si aplica)
    player_opt = ["-p", args.player] if args.player else []
    base_cmd = ["playerctl"] + player_opt

    # Ejecutar acciones y salir
    if args.prev:
        subprocess.run(base_cmd + ["previous"])
        return
    if args.next:
        subprocess.run(base_cmd + ["next"])
        return
    if args.play_pause:
        subprocess.run(base_cmd + ["play-pause"])
        return
    if args.vol_up:
        subprocess.run(base_cmd + ["volume", f"{args.volume_step}+"])
        return
    if args.vol_down:
        subprocess.run(base_cmd + ["volume", f"{args.volume_step}-"])
        return

    # Si no hay acción, mostrar widget según --widget
    if not args.widget:
        parser.print_help()
        sys.exit(1)

    status = get_status(args.player)
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
    artist, title = get_metadata(args.player)
    state_icon_str = state_icon(status, icons)
    tags = {
        "artist": artist,
        "title": title,
        "state": state_icon_str,
    }
    try:
        text = args.format.format(**tags)
    except KeyError:
        text = args.format  # fallback
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
