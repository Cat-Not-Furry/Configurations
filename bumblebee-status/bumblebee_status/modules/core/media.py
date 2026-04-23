# pylint: disable=C0111,R0903

from collections import defaultdict
import string

import core.module
import core.input
import core.decorators

import util.cli


class Module(core.module.Module):
    def __init__(self, config, theme):
        super().__init__(config, theme, [])

        self._layout = self.parameter(
            "layout", "media.prev media.main media.next"
        )

        self._fmt = self.parameter(
            "format", "{state} {artist} - {title}"
        )

        self._player = self.parameter("player", None)
        self._volume_step = float(self.parameter("volume_step", 0.05))

        # ✅ iconos configurables
        self._icons = {
            "prev": self.parameter("icon_prev", "⏮"),
            "next": self.parameter("icon_next", "⏭"),
            "play": self.parameter("icon_play", "▶"),
            "pause": self.parameter("icon_pause", "⏸"),
            "stop": self.parameter("icon_stop", "⏹"),
        }

        self._status = None
        self._tags = defaultdict(lambda: "")

        self._cmd = "playerctl"
        if self._player:
            self._cmd = f"{self._cmd} -p {self._player}"

        self._widget_map = {}

        for widget_name in self._layout.split():
            widget = self.add_widget(name=widget_name)

            if widget_name == "media.prev":
                widget.full_text(self._icons["prev"])  # icono directo
                self._widget_map[widget] = {
                    "button": core.input.LEFT_MOUSE,
                    "cmd": f"{self._cmd} previous",
                    "state": "prev",
                }

            elif widget_name == "media.main":
                self._widget_map[widget] = {
                    "button": core.input.LEFT_MOUSE,
                    "cmd": f"{self._cmd} play-pause",
                    "state": None,
                }
                widget.full_text(self.description)

            elif widget_name == "media.next":
                widget.full_text(self._icons["next"])  # icono directo
                self._widget_map[widget] = {
                    "button": core.input.LEFT_MOUSE,
                    "cmd": f"{self._cmd} next",
                    "state": "next",
                }

            else:
                raise KeyError(f"Unsupported widget {widget_name}")

        # clicks
        for widget, options in self._widget_map.items():
            core.input.register(widget, button=options["button"], cmd=options["cmd"])

        # scroll volumen
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
        util.cli.execute(f"{self._cmd} volume {self._volume_step}+")

    def decrease_volume(self, event):
        util.cli.execute(f"{self._cmd} volume {self._volume_step}-")

    def _load(self):
        try:
            self._status = util.cli.execute(f"{self._cmd} status").strip()

            meta = util.cli.execute(
                f'{self._cmd} metadata -f "{{{{artist}}}}|||{{{{title}}}}"'
            ).strip()

            artist, title = (meta.split("|||") + ["", ""])[:2]

            self._tags.update({
                "artist": artist or "",
                "title": title or "",
                "state": self._state_icon(),
            })

        except RuntimeError:
            self._status = None
            self._tags = defaultdict(lambda: "")
