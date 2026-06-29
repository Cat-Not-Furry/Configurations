# pylint: disable=C0111,R0903

"""Displays keyboard backlight level (read-only).

Reads brightness from /sys/class/leds/<device>/brightness. The device name
defaults to tpacpi::kbd_backlight and can be overridden with kbdlight.device
or the [kbdlight] section in cnf-bin/config.toml.

Parameters:
    * kbdlight.device: LED device name under /sys/class/leds/ (defaults to tpacpi::kbd_backlight)
    * kbdlight.config: Path to cnf-bin config.toml (defaults to auto-detect)
"""

import os
import re

import core.module
import core.widget
import core.decorators


DEFAULT_DEVICE = "tpacpi::kbd_backlight"


def _resolve_config_file(explicit):
    if explicit:
        path = os.path.expanduser(explicit)
        if os.path.isfile(path):
            return path
        return None

    candidates = []
    env_config = os.environ.get("CNF_BIN_CONFIG")
    if env_config:
        candidates.append(os.path.expanduser(env_config))
    candidates.append(os.path.expanduser("~/.config/cnf-bin/config.toml"))

    for path in candidates:
        if os.path.isfile(path):
            return path
    return None


def _read_kbd_device_from_toml(path):
    in_section = False
    pattern = re.compile(r'^device\s*=\s*"([^"]*)"')

    with open(path, encoding="utf-8") as handle:
        for line in handle:
            stripped = line.strip()
            if stripped == "[kbdlight]":
                in_section = True
                continue
            if stripped.startswith("[") and in_section:
                break
            if in_section:
                match = pattern.match(stripped)
                if match:
                    return match.group(1).strip()
    return None


class Module(core.module.Module):
    @core.decorators.every(seconds=10)
    def __init__(self, config, theme):
        super().__init__(config, theme, core.widget.Widget(self.output))

        self.__brightness = ""
        self.__device_missing = True

        device = self.parameter("device")
        if not device:
            config_file = _resolve_config_file(self.parameter("config"))
            if config_file:
                device = _read_kbd_device_from_toml(config_file)
        self.__device = device or DEFAULT_DEVICE
        self.__led_path = "/sys/class/leds/{}/brightness".format(self.__device)
        self.__max_path = "/sys/class/leds/{}/max_brightness".format(self.__device)

        if self.parameter("scrolling.makewide") is None:
            self.set("scrolling.makewide", False)

    def hidden(self):
        return self.__device_missing or self.__brightness == ""

    def output(self, _):
        return self.__brightness

    def update(self):
        if not os.path.isfile(self.__led_path):
            self.__device_missing = True
            self.__brightness = ""
            return

        self.__device_missing = False

        try:
            with open(self.__led_path, encoding="utf-8") as handle:
                current = int(handle.read().strip())
        except (IOError, OSError, ValueError):
            self.__brightness = "n/a"
            return

        if current <= 0:
            self.__brightness = ""
            return

        max_brightness = current
        if os.path.isfile(self.__max_path):
            try:
                with open(self.__max_path, encoding="utf-8") as handle:
                    max_brightness = int(handle.read().strip())
            except (IOError, OSError, ValueError):
                max_brightness = current

        if max_brightness <= 0:
            max_brightness = current

        self.__brightness = "{:3.0f}%".format(float(current) * 100.0 / float(max_brightness))


# vim: tabstop=8 expandtab shiftwidth=4 softtabstop=4
