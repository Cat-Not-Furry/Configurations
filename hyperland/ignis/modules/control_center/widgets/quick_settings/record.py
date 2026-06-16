import asyncio
import os
import subprocess
from ignis import utils, widgets
from ...qs_button import QSButton
from ...menu import Menu

START_VIDEO_SCRIPT = os.path.expanduser("~/.config/ignis/scripts/start-video-only.sh")
START_AUDIO_SCRIPT = os.path.expanduser("~/.config/ignis/scripts/start-audio-video.sh")
STOP_SCRIPT = os.path.expanduser("~/.config/ignis/scripts/stop-recording.sh")
STATE_PID_FILE = os.path.expanduser("~/.cache/ignis/recording.pid")
STATE_TYPE_FILE = os.path.expanduser("~/.cache/ignis/recording.type")


class RecordMenu(Menu):
    def __init__(self, on_select, name: str, **kwargs):
        self._on_select = on_select
        self._is_recording = False
        self._current_type = None

        self.video_label = widgets.Label(
            label="Grabar (sin audio)",
            halign="start",
            css_classes=["user-settings-menu-label"],
        )
        self.audio_label = widgets.Label(
            label="Grabar (con audio)",
            halign="start",
            css_classes=["user-settings-menu-label"],
        )
        self.stop_label = widgets.Label(
            label="Detener grabación",
            halign="start",
            css_classes=["user-settings-menu-label"],
        )

        self.video_btn = widgets.Button(
            css_classes=["user-settings-menu-item", "unset"],
            on_click=self._toggle_video_callback,
            child=widgets.Box(
                child=[
                    widgets.Icon(icon_name="audio-volume-muted-symbolic"),
                    self.video_label,
                ]
            ),
        )
        self.audio_btn = widgets.Button(
            css_classes=["user-settings-menu-item", "unset"],
            on_click=self._toggle_audio_callback,
            child=widgets.Box(
                child=[
                    widgets.Icon(icon_name="audio-volume-high-symbolic"),
                    self.audio_label,
                ]
            ),
        )
        self.stop_btn = widgets.Button(
            css_classes=["user-settings-menu-item", "unset"],
            on_click=self._stop_recording_callback,
            child=widgets.Box(
                child=[
                    widgets.Icon(icon_name="media-playback-stop-symbolic"),
                    self.stop_label,
                ]
            ),
        )

        super().__init__(
            name=name,
            transition_type="slide_up",
            vertical=True,
            child=[self.audio_btn, self.video_btn, self.stop_btn],
            **kwargs,
        )

        self.connect("notify::reveal-child", self._on_reveal)

    def _on_reveal(self, _, __):
        if self.reveal_child:
            self._refresh_state()

    def _refresh_state(self):
        recording = False
        rec_type = None

        if os.path.exists(STATE_PID_FILE) and os.path.exists(STATE_TYPE_FILE):
            try:
                with open(STATE_TYPE_FILE, "r") as f:
                    rec_type = f.read().strip()
                with open(STATE_PID_FILE, "r") as f:
                    pid = int(f.read().strip())
                if subprocess.run(["kill", "-0", str(pid)], capture_output=True).returncode == 0:
                    recording = True
                else:
                    self._clean_state_files()
            except Exception:
                self._clean_state_files()

        self._is_recording = recording
        self._current_type = rec_type if recording else None

        if self._is_recording and self._current_type == "video":
            self.video_label.set_label("Detener grabación (sin audio)")
            self.audio_label.set_label("Grabar (con audio)")
        elif self._is_recording and self._current_type == "audio":
            self.audio_label.set_label("Detener grabación (con audio)")
            self.video_label.set_label("Grabar (sin audio)")
        else:
            self.video_label.set_label("Grabar (sin audio)")
            self.audio_label.set_label("Grabar (con audio)")

    def _clean_state_files(self):
        for f in [STATE_PID_FILE, STATE_TYPE_FILE]:
            if os.path.exists(f):
                os.remove(f)

    def _toggle_video_callback(self, _):
        asyncio.create_task(self._toggle_video())

    def _toggle_audio_callback(self, _):
        asyncio.create_task(self._toggle_audio())

    def _stop_recording_callback(self, _):
        asyncio.create_task(self._stop_only())

    async def _stop_only(self):
        if self._is_recording:
            await utils.exec_sh_async(f"bash {STOP_SCRIPT}")
            await asyncio.sleep(0.5)
            self._refresh_state()
            self._on_select()

    async def _stop_current(self):
        if self._is_recording:
            await utils.exec_sh_async(f"bash {STOP_SCRIPT}")
            await asyncio.sleep(0.5)
            self._refresh_state()

    async def _toggle_video(self):
        if self._is_recording and self._current_type == "video":
            await self._stop_current()
        else:
            if self._is_recording:
                await self._stop_current()
            await utils.exec_sh_async(f"bash {START_VIDEO_SCRIPT}")
            await asyncio.sleep(0.5)
            self._refresh_state()
            self._on_select()

    async def _toggle_audio(self):
        if self._is_recording and self._current_type == "audio":
            await self._stop_current()
        else:
            if self._is_recording:
                await self._stop_current()
            await utils.exec_sh_async(f"bash {START_AUDIO_SCRIPT}")
            await asyncio.sleep(0.5)
            self._refresh_state()
            self._on_select()


class RecordButton(widgets.Button):
    def __init__(self):
        self.menu_instance = RecordMenu(
            name="record-menu",
            on_select=lambda: self.menu_instance.toggle()
        )
        self._icon_widget = widgets.Icon(icon_name="media-record-symbolic")
        self._label_widget = widgets.Label(label="Grabar")
        self._arrow_icon = widgets.Icon(icon_name="", halign="end", hexpand=True)

        content = widgets.Box(
            child=[self._icon_widget, self._label_widget, self._arrow_icon],
            spacing=6,
            halign="center",
        )

        super().__init__(
            child=content,
            css_classes=["qs-button"],
        )

        self.menu = self.menu_instance
        self.connect("clicked", self._toggle_menu)
        self.menu_instance.connect("notify::reveal-child", self._update_active)
        self.menu_instance.connect("notify::reveal-child", self._update_arrow)

        self._update_task = None
        self._start_periodic_update()

    def _start_periodic_update(self):
        async def periodic():
            while True:
                await asyncio.sleep(2)
                await self._update_recording_status()

        self._update_task = asyncio.create_task(periodic())

    async def _update_recording_status(self):
        if os.path.exists(STATE_PID_FILE) and os.path.exists(STATE_TYPE_FILE):
            try:
                with open(STATE_TYPE_FILE, "r") as f:
                    rec_type = f.read().strip()
                with open(STATE_PID_FILE, "r") as f:
                    pid = int(f.read().strip())
                if subprocess.run(["kill", "-0", str(pid)], capture_output=True).returncode == 0:
                    self.add_css_class("recording")
                    self._icon_widget.set_icon_name("media-record-running-symbolic")
                    self._label_widget.set_label("Grabando...")
                    return
            except:
                pass

        self.remove_css_class("recording")
        self._icon_widget.set_icon_name("media-record-symbolic")
        self._label_widget.set_label("Grabar")

    def _toggle_menu(self, _):
        self.menu_instance.toggle()

    def _update_active(self, menu, _):
        if menu.reveal_child:
            self.add_css_class("active")
        else:
            self.remove_css_class("active")

    def _update_arrow(self, menu, _):
        if menu.reveal_child:
            self._arrow_icon.set_icon_name("go-down-symbolic")
        else:
            self._arrow_icon.set_icon_name("go-next-symbolic")