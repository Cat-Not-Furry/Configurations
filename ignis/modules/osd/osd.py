from gi.repository import GLib  # type: ignore
from ignis import widgets
from ignis import utils
from ignis.services.audio import AudioService
from ..bar_position import bar_margin_offset, get_bar_position, read_cached_bar_position
from ..shared_widgets import MaterialVolumeSlider

audio = AudioService.get_default()


class OSD(widgets.Window):
    def __init__(self):
        self._bar_position = "top"
        self._content = widgets.Box(
            css_classes=["osd"],
            child=[
                widgets.Icon(
                    pixel_size=26,
                    style="margin-right: 0.5rem;",
                    image=audio.speaker.bind("icon_name"),
                ),
                MaterialVolumeSlider(stream=audio.speaker, sensitive=False),
            ],
        )

        super().__init__(
            layer="overlay",
            anchor=["bottom"],
            namespace="ignis_OSD",
            visible=False,
            css_classes=["rec-unset"],
            child=self._content,
        )

        self._apply_bar_position(get_bar_position())
        GLib.timeout_add(500, self._poll_bar_position)

    def _apply_bar_position(self, position: str) -> None:
        self._bar_position = position
        if position == "bottom":
            self._content.margin_bottom = bar_margin_offset()
        else:
            self._content.margin_bottom = 0

    def _poll_bar_position(self) -> bool:
        position = read_cached_bar_position() or get_bar_position()
        if position != self._bar_position:
            self._apply_bar_position(position)
        elif position == "bottom":
            self._content.margin_bottom = bar_margin_offset()
        return True

    def set_property(self, property_name, value):
        if property_name == "visible":
            self.__update_visible()

        super().set_property(property_name, value)

    @utils.debounce(3000)
    def __update_visible(self) -> None:
        super().set_property("visible", False)
