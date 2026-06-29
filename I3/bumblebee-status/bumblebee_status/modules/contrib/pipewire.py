"""get volume level or control it

Requires the following executable:
    * wpctl

Parameters:
    * pipewire.percent_change: How much to change volume by when scrolling on the module (default is 4%)
    * pipewire.max_volume: Cap as percent (default 200 → wpctl --limit 2.0)
"""
import re

import core.input
import core.module
import core.widget

import util.cli
import util.format


class Module(core.module.Module):
    def __init__(self, config, theme):
        super().__init__(config, theme, core.widget.Widget(self.volume))

        self.__level = "N/A"
        self.__muted = True
        self.__change = (
            util.format.asint(self.parameter("percent_change", "4%").strip("%"), 0, 200)
            / 100.0
        )

        self.__id = self.parameter("sink_id") or "@DEFAULT_AUDIO_SINK@"
        limit_pct = util.format.asint(
            self.parameter("max_volume", "200%").strip("%"), 0, 200
        )
        self.__limit = limit_pct / 100.0

        events = [
            {
                "type": "mute",
                "action": self.toggle,
                "button": core.input.LEFT_MOUSE,
            },
            {
                "type": "volume",
                "action": self.increase_volume,
                "button": core.input.WHEEL_UP,
            },
            {
                "type": "volume",
                "action": self.decrease_volume,
                "button": core.input.WHEEL_DOWN,
            },
        ]

        for event in events:
            core.input.register(self, button=event["button"], cmd=event["action"])

    def toggle(self, event):
        util.cli.execute("wpctl set-mute {} toggle".format(self.__id))

    def increase_volume(self, event):
        util.cli.execute(
            "wpctl set-volume --limit {} {} {}+".format(
                self.__limit, self.__id, self.__change
            )
        )

    def decrease_volume(self, event):
        util.cli.execute(
            "wpctl set-volume --limit {} {} {}-".format(
                self.__limit, self.__id, self.__change
            )
        )

    def volume(self, widget):
        if self.__level == "N/A":
            return self.__level
        return "{}%".format(int(float(self.__level) * 100))

    def update(self):
        try:
            volume = util.cli.execute("wpctl get-volume {}".format(self.__id))
            v = re.search(r"\d\.\d+", volume)
            m = re.search("MUTED", volume)
            self.__level = v.group()
            self.__muted = True if m else False
        except Exception:
            self.__level = "N/A"

    def state(self, widget):
        if self.__muted:
            return ["warning", "muted"]
        return ["unmuted"]
