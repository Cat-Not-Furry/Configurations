import asyncio
from typing import Literal

from ignis import utils
from ignis import widgets
from ignis.services.audio import AudioService, Stream

from ..menu import Menu
from ...shared_widgets import MaterialVolumeSlider
from .audio_helpers import (
    PortInfo,
    device_icon,
    format_port_subtitle,
    get_ports,
    has_any_available_port,
    set_port,
    short_label_for_stream,
    sort_streams,
)

audio = AudioService.get_default()

AUDIO_TYPES = {
    "speaker": {"menu_icon": "audio-headphones-symbolic", "menu_label": "Salida de audio"},
    "microphone": {
        "menu_icon": "microphone-sensitivity-high-symbolic",
        "menu_label": "Entrada de audio",
    },
}

DeviceKind = Literal["speaker", "microphone"]


class PortItem(widgets.Button):
    def __init__(self, stream: Stream, port: PortInfo):
        label = port.label
        if not port.available:
            label += " (desconectado)"

        super().__init__(
            child=widgets.Box(
                child=[
                    widgets.Label(
                        label=label,
                        ellipsize="end",
                        halign="start",
                        css_classes=["volume-entry-label"],
                    ),
                    widgets.Icon(
                        image="object-select-symbolic",
                        halign="end",
                        hexpand=True,
                        visible=port.is_active,
                    ),
                ]
            ),
            css_classes=["volume-entry", "volume-entry-port", "unset"],
            sensitive=port.available,
            hexpand=True,
            on_click=lambda _: set_port(stream, port.id),
        )


class PortSubmenu(widgets.Box):
    def __init__(self, stream: Stream, ports: list[PortInfo]):
        if len(ports) <= 1:
            super().__init__(visible=False)
            return

        super().__init__(
            vertical=True,
            child=[PortItem(stream, port) for port in ports],
        )


class DeviceItem(widgets.Box):
    def __init__(
        self,
        stream: Stream,
        kind: DeviceKind,
        short_label: str,
    ):
        ports = get_ports(stream)
        unavailable = not has_any_available_port(stream)
        css_classes = ["volume-entry", "unset"]
        if unavailable:
            css_classes.append("volume-entry-unavailable")

        main_button = widgets.Button(
            child=widgets.Box(
                child=[
                    widgets.Icon(
                        image=device_icon(stream.description, kind, stream),
                    ),
                    widgets.Box(
                        vertical=True,
                        hexpand=True,
                        halign="start",
                        child=[
                            widgets.Label(
                                label=short_label,
                                ellipsize="end",
                                max_width_chars=45,
                                halign="start",
                                css_classes=["volume-entry-label"],
                            ),
                            widgets.Label(
                                label=format_port_subtitle(ports),
                                ellipsize="end",
                                max_width_chars=45,
                                halign="start",
                                css_classes=["volume-entry-sublabel"],
                            ),
                        ],
                    ),
                    widgets.Icon(
                        image="object-select-symbolic",
                        halign="end",
                        visible=stream.bind("is_default"),
                    ),
                ]
            ),
            css_classes=css_classes,
            hexpand=True,
            on_click=lambda _: setattr(audio, kind, stream),
        )

        super().__init__(
            vertical=True,
            child=[main_button, PortSubmenu(stream, ports)],
            setup=lambda self: stream.connect("removed", lambda _: self.unparent()),
        )


class DeviceMenu(Menu):
    def __init__(self, kind: DeviceKind, style: str = ""):
        data = AUDIO_TYPES[kind]
        self._kind = kind
        self._list_box = widgets.Box(vertical=True)
        self._seen_ids: set[int] = set()

        super().__init__(
            name=f"volume-{kind}",
            child=[
                widgets.Box(
                    child=[
                        widgets.Icon(image=data["menu_icon"], pixel_size=24),
                        widgets.Label(
                            label=data["menu_label"],
                            halign="start",
                            css_classes=["volume-entry-list-header-label"],
                        ),
                    ],
                    css_classes=["volume-entry-list-header-box"],
                ),
                self._list_box,
                widgets.Separator(css_classes=["volume-entry-list-separator"]),
                widgets.Button(
                    child=widgets.Box(
                        child=[
                            widgets.Icon(image="preferences-system-symbolic"),
                            widgets.Label(
                                label="Ajustes de sonido",
                                halign="start",
                                css_classes=["volume-entry-label"],
                            ),
                        ]
                    ),
                    css_classes=["volume-entry", "unset"],
                    style="margin-bottom: 0;",
                    on_click=lambda _: asyncio.create_task(
                        utils.exec_sh_async("pavucontrol")
                    ),
                ),
            ],
        )

        self.box.add_css_class(f"volume-menubox-{kind}")
        self._populate()

        audio.connect(f"{kind}-added", lambda _, stream: self._append_stream(stream))

    def _populate(self) -> None:
        for stream in sort_streams(getattr(audio, f"{self._kind}s")):
            self._append_stream(stream)

    def _append_stream(self, stream: Stream) -> None:
        if stream.id in self._seen_ids:
            return
        self._seen_ids.add(stream.id)

        siblings = sort_streams(getattr(audio, f"{self._kind}s"))
        label = short_label_for_stream(stream, siblings)
        self._list_box.append(DeviceItem(stream, self._kind, label))


class VolumeSlider(widgets.Box):
    def __init__(self, kind: DeviceKind):
        stream = getattr(audio, kind)

        icon = widgets.Button(
            child=widgets.Icon(
                image=stream.bind("icon_name"),
                pixel_size=18,
            ),
            css_classes=["material-slider-icon", "unset", "hover-surface"],
            on_click=lambda _: stream.set_is_muted(not stream.is_muted),
        )

        device_menu = DeviceMenu(kind=kind)

        scale = MaterialVolumeSlider(
            stream=stream,
            on_change=lambda x: stream.set_volume(x.value),
            sensitive=stream.bind("is_muted", lambda value: not value),
        )

        arrow = widgets.Button(
            child=widgets.Arrow(
                pixel_size=20, rotated=device_menu.bind("reveal_child")
            ),
            css_classes=["material-slider-arrow", "hover-surface"],
            on_click=lambda _: device_menu.toggle(),
        )
        super().__init__(
            vertical=True,
            child=[
                widgets.Box(child=[icon, scale, arrow]),
                device_menu,
            ],
            css_classes=[f"volume-mainbox-{kind}"],
        )
