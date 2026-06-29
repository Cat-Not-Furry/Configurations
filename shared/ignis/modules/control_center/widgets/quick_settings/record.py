import asyncio
import os
from ignis import utils, widgets
from ...qs_button import QSButton
from ...menu import Menu

START_VIDEO_SCRIPT = os.path.expanduser("~/.config/ignis/scripts/start-video-only.sh")
START_AUDIO_SCRIPT = os.path.expanduser("~/.config/ignis/scripts/start-audio-video.sh")
STOP_SCRIPT = os.path.expanduser("~/.config/ignis/scripts/stop-recording.sh")
STATUS_SCRIPT = os.path.expanduser("~/.config/ignis/scripts/recording-status.sh")

RECORDING_STATES = ("video", "audio", "unknown")


def get_recording_status_sync() -> str:
    return utils.exec_sh(f"bash {STATUS_SCRIPT}").stdout.strip()


async def get_recording_status() -> str:
    result = await utils.exec_sh_async(f"bash {STATUS_SCRIPT}")
    return result.stdout.strip()


def is_recording_status(status: str) -> bool:
    return status in RECORDING_STATES


class RecordMenu(Menu):
    def __init__(self, on_started, name: str, **kwargs):
        self._on_started = on_started

        self.video_btn = widgets.Button(
            css_classes=["network-item", "unset"],
            on_click=self._start_video_callback,
            child=widgets.Box(
                child=[
                    widgets.Icon(icon_name="audio-volume-muted-symbolic"),
                    widgets.Label(
                        label="Grabar (sin audio)",
                        halign="start",
                    ),
                ]
            ),
        )
        self.audio_btn = widgets.Button(
            css_classes=["network-item", "unset"],
            on_click=self._start_audio_callback,
            child=widgets.Box(
                child=[
                    widgets.Icon(icon_name="audio-volume-high-symbolic"),
                    widgets.Label(
                        label="Grabar (con audio)",
                        halign="start",
                    ),
                ]
            ),
        )

        super().__init__(
            name=name,
            child=[self.audio_btn, self.video_btn],
            **kwargs,
        )

        self.connect("notify::reveal-child", self._on_reveal)

    def _on_reveal(self, _, __):
        if self.reveal_child and get_recording_status_sync() != "none":
            self.toggle()

    def _start_video_callback(self, _):
        asyncio.create_task(self._start_video())

    def _start_audio_callback(self, _):
        asyncio.create_task(self._start_audio())

    async def _start_video(self):
        result = await utils.exec_sh_async(f"bash {START_VIDEO_SCRIPT}")
        if result.returncode != 0:
            return
        await asyncio.sleep(0.5)
        if not is_recording_status(await get_recording_status()):
            return
        await self._on_started()

    async def _start_audio(self):
        result = await utils.exec_sh_async(f"bash {START_AUDIO_SCRIPT}")
        if result.returncode != 0:
            return
        await asyncio.sleep(0.5)
        if not is_recording_status(await get_recording_status()):
            return
        await self._on_started()


class RecordButton(QSButton):
    def __init__(self):
        self.menu_instance = RecordMenu(
            name="record-menu",
            on_started=self._on_recording_started,
        )

        super().__init__(
            label="Grabar",
            icon_name="media-record-symbolic",
            menu=self.menu_instance,
        )

        box = self.get_child()
        if box:
            self._icon_widget = box.get_first_child()
            self._label_widget = (
                self._icon_widget.get_next_sibling() if self._icon_widget else None
            )
        else:
            self._icon_widget = None
            self._label_widget = None

        self._start_periodic_update()

        # QSButton registra _QSButton__callback en on_click; no se puede
        # sobreescribir con otro __callback por name mangling de Python.
        self.on_click = self._record_click_handler

    def _record_click_handler(self, _):
        asyncio.create_task(self._handle_click())

    def _start_periodic_update(self):
        async def periodic():
            while True:
                await asyncio.sleep(2)
                await self._update_ui()

        asyncio.create_task(periodic())

    async def _on_recording_started(self):
        if self.menu_instance.reveal_child:
            self.menu_instance.toggle()
        await self._update_ui()

    async def _handle_click(self):
        status = await get_recording_status()

        if is_recording_status(status):
            await utils.exec_sh_async(f"bash {STOP_SCRIPT}")
            await asyncio.sleep(0.5)
        else:
            self.menu_instance.toggle()
            self.active = self.menu_instance.reveal_child

        await self._update_ui()

    async def _update_ui(self):
        if not self._icon_widget or not self._label_widget:
            return

        status = await get_recording_status()
        recording = is_recording_status(status)

        if recording:
            self.remove_css_class("active")
            self.add_css_class("recording")
            self._icon_widget.image = "media-record-running-symbolic"
            self._label_widget.set_label("Grabando...")
            if self._arrow_icon_widget:
                self._arrow_icon_widget.set_visible(False)
            if self.menu_instance.reveal_child:
                self.menu_instance.toggle()
            return

        self.remove_css_class("recording")
        self._icon_widget.image = "media-record-symbolic"
        self._label_widget.set_label("Grabar")
        if self._arrow_icon_widget:
            self._arrow_icon_widget.set_visible(True)
        self.active = self.menu_instance.reveal_child
