# pylint: disable=C0111,R0903

import json
import string
from collections import defaultdict

import core.decorators
import core.input
import core.module

import util.cli


class Module(core.module.Module):
    CNF_MEDIA = "cnf-media"

    def __init__(self, config, theme):
        super().__init__(config, theme, [])

        self._layout = self.parameter(
            "layout", "media.prev media.main media.next"
        )

        self._fmt = self.parameter(
            "format", "{state} {artist} - {title}"
        )

        self._icons = {
            "prev": self.parameter("icon_prev", "⏮"),
            "next": self.parameter("icon_next", "⏭"),
            "play": self.parameter("icon_play", "▶"),
            "pause": self.parameter("icon_pause", "⏸"),
            "stop": self.parameter("icon_stop", "⏹"),
        }

        self._status = None
        self._tags = defaultdict(lambda: "")

        self._widget_map = {}

        for widget_name in self._layout.split():
            widget = self.add_widget(name=widget_name)

            if widget_name == "media.prev":
                widget.full_text(self._icons["prev"])
                self._widget_map[widget] = {
                    "button": core.input.LEFT_MOUSE,
                    "cmd": f"{self.CNF_MEDIA} --prev",
                    "state": "prev",
                }

            elif widget_name == "media.main":
                self._widget_map[widget] = {
                    "button": core.input.LEFT_MOUSE,
                    "cmd": f"{self.CNF_MEDIA} --play-pause",
                    "state": None,
                }
                widget.full_text(self.description)

            elif widget_name == "media.next":
                widget.full_text(self._icons["next"])
                self._widget_map[widget] = {
                    "button": core.input.LEFT_MOUSE,
                    "cmd": f"{self.CNF_MEDIA} --next",
                    "state": "next",
                }

            else:
                raise KeyError(f"Unsupported widget {widget_name}")

        for widget, options in self._widget_map.items():
            core.input.register(widget, button=options["button"], cmd=options["cmd"])

        core.input.register(self, button=core.input.WHEEL_UP, cmd=self.increase_volume)
        core.input.register(self, button=core.input.WHEEL_DOWN, cmd=self.decrease_volume)

    def hidden(self):
        return self._status is None

    @core.decorators.scrollable
    def description(self, widget):
        return string.Formatter().vformat(self._fmt, (), self._tags)

    def update(self):
        self._load()

    def state(self, widget):
        info = self._widget_map.get(widget, {})
        if info.get("state") is not None:
            return info["state"]
        return self._status

    def _state_icon(self):
        return {
            "Playing": self._icons["play"],
            "Paused": self._icons["pause"],
            "Stopped": self._icons["stop"],
        }.get(self._status, "?")

    def increase_volume(self, event):
        util.cli.execute(f"{self.CNF_MEDIA} --vol-up")

    def decrease_volume(self, event):
        util.cli.execute(f"{self.CNF_MEDIA} --vol-down")

    def _load(self):
        try:
            util.cli.execute(f"{self.CNF_MEDIA} --refresh")
            cache = self._read_cache()
            if not cache.get("player") or not cache.get("status"):
                self._status = None
                self._tags = defaultdict(lambda: "")
                return

            self._status = cache["status"]
            self._tags.update({
                "artist": cache.get("artist") or "",
                "title": cache.get("title") or "",
                "state": self._state_icon(),
            })

        except (RuntimeError, json.JSONDecodeError, KeyError, OSError):
            self._status = None
            self._tags = defaultdict(lambda: "")

    def _read_cache(self):
        import os

        cache_home = os.environ.get("XDG_CACHE_HOME") or os.path.join(
            os.path.expanduser("~"), ".cache"
        )
        path = os.path.join(cache_home, "cnf-bin", "media.json")
        with open(path, encoding="utf-8") as f:
            return json.load(f)
