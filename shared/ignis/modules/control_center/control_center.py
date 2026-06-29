from gi.repository import GLib  # type: ignore
from ignis import widgets
from ignis.window_manager import WindowManager
from ..bar_position import bar_margin_offset, get_bar_position, read_cached_bar_position
from .widgets import (
    QuickSettings,
    Brightness,
    VolumeSlider,
    User,
    Media,
)
from .menu import opened_menu

window_manager = WindowManager.get_default()


class ControlCenter(widgets.RevealerWindow):
    def __init__(self):
        panel_content = widgets.Box(
            vertical=True,
            vexpand=False,
            css_classes=["control-center"],
            child=[
                widgets.Box(
                    vertical=True,
                    vexpand=False,
                    css_classes=["control-center-widget"],
                    child=[
                        QuickSettings(),
                        VolumeSlider("speaker"),
                        VolumeSlider("microphone"),
                        Brightness(),
                        User(),
                    ],
                ),
                Media(),
            ],
        )

        revealer = widgets.Revealer(
            transition_type="slide_left",
            child=panel_content,
            transition_duration=100,
            reveal_child=True,
        )

        self._revealer = revealer
        self._bar_position = "top"
        self._panel_box = widgets.Box(
            hexpand=False,
            vexpand=False,
            halign="end",
            valign="start",
            child=[revealer],
        )

        super().__init__(
            visible=False,
            popup=True,
            kb_mode="on_demand",
            layer="top",
            css_classes=["unset"],
            anchor=["top", "right", "bottom", "left"],
            namespace="ignis_CONTROL_CENTER",
            child=widgets.Box(
                hexpand=True,
                vexpand=True,
                child=[
                    widgets.EventBox(
                        hexpand=True,
                        vexpand=True,
                        css_classes=["control-center-dismiss"],
                        on_click=lambda x: setattr(self, "visible", False),
                    ),
                    self._panel_box,
                ],
            ),
            setup=lambda self: self.connect(
                "notify::visible", lambda x, y: opened_menu.set_value("")
            ),
            revealer=revealer,
        )

        self._apply_bar_position(get_bar_position())
        GLib.timeout_add(500, self._poll_bar_position)

    def _apply_bar_position(self, position: str) -> None:
        self._bar_position = position
        if position == "bottom":
            self._panel_box.valign = "end"
            self._panel_box.margin_bottom = bar_margin_offset()
        else:
            self._panel_box.valign = "start"
            self._panel_box.margin_bottom = 0

    def _poll_bar_position(self) -> bool:
        position = read_cached_bar_position() or get_bar_position()
        if position != self._bar_position:
            self._apply_bar_position(position)
        elif position == "bottom":
            self._panel_box.margin_bottom = bar_margin_offset()
        return True
