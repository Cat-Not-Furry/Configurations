# ~/.config/bumblebee-status/modules/keyboard.py

import core.module
import core.widget
import core.input
import util.cli
import re


class Module(core.module.Module):
    def __init__(self, config, theme):
        super().__init__(config, theme, core.widget.Widget(self.output))

        self._keyboard_name = self.parameter("name", "AT Translated Set 2 keyboard")

        core.input.register(self, button=core.input.LEFT_MOUSE, cmd=self._toggle)

    # -----------------------------------------------------

    def _get_device_id(self):
        try:
            res = util.cli.execute(f'xinput list --id-only "{self._keyboard_name}"')
            return res.strip()
        except Exception:
            return None

    # -----------------------------------------------------

    def _get_master_id(self):
        try:
            res = util.cli.execute("xinput list")
            for line in res.split("\n"):
                if "Virtual core keyboard" in line:
                    match = re.search(r"id=(\d+)", line)
                    if match:
                        return match.group(1)
        except Exception:
            return None

    # -----------------------------------------------------

    def _is_attached(self):
        device_id = self._get_device_id()
        if not device_id:
            return False

        try:
            res = util.cli.execute("xinput list")
            for line in res.split("\n"):
                if f"id={device_id}" in line:
                    return "floating" not in line.lower()
        except Exception:
            return False

        return False

    # -----------------------------------------------------

    def _toggle(self, event):
        device_id = self._get_device_id()
        master_id = self._get_master_id()

        if not device_id or not master_id:
            return

        if self._is_attached():
            util.cli.execute(f"xinput float {device_id}")
        else:
            util.cli.execute(f"xinput reattach {device_id} {master_id}")

    # -----------------------------------------------------

    def output(self, widget):
        return "ON" if self._is_attached() else "OFF"

    def update(self):
        pass  # No necesitamos estado cacheado

    def state(self, widget):
        return "ON" if self._is_attached() else "OFF"
