import asyncio
import json
import os
from pathlib import Path

from gi.repository import GLib, Gtk  # type: ignore

from ignis import widgets
from ignis import utils
from ignis.services.fetch import FetchService
from user_options import user_options
from ..qs_button import QSButton
from ..menu import Menu
from ...powermenu import toggle_power_menu
from ...wallpaper_picker import (
    toggle_wallpaper_picker,
    toggle_image_wallpaper_picker,
    toggle_other_image_wallpaper_picker,
)
from ...theme_loader import (
    get_active_theme_id,
    get_hover_hint_ms,
    get_next_theme_id,
    get_theme_label,
)

fetch = FetchService.get_default()

ICON_MOON = "\uf186"
ICON_COLD = "\uf2dc"
ICON_WARM = "\uf185"

APPLY_THEME_SCRIPT = Path.home() / ".config/hypr/scripts/apply-theme.sh"
HYPRSUNSET_STATE = Path.home() / ".cache/ignis/hyprsunset.state"
HYPRSUNSET_SCRIPTS = Path.home() / ".config/hypr/scripts"
TEMP_MIN = 1000
TEMP_MAX = 20000
TEMP_STEP = 1000


def snap_temperature(temp: int) -> int:
    temp = max(TEMP_MIN, min(TEMP_MAX, temp))
    return round(temp / TEMP_STEP) * TEMP_STEP


def format_uptime(value: tuple[int, int, int, int]) -> str:
    days, hours, minutes, seconds = value
    if days:
        return f"encendido {days:02}:{hours:02}:{minutes:02}"
    else:
        return f"encendido {hours:02}:{minutes:02}"


def _resolve_apply_theme_script() -> Path:
    if APPLY_THEME_SCRIPT.is_file():
        return APPLY_THEME_SCRIPT
    return Path(__file__).resolve().parents[4] / "scripts" / "apply-theme.sh"


class ThemeCycleButton(widgets.Box):
    def __init__(self):
        self._hover_timer_id: int | None = None
        self._button = widgets.Button(
            child=widgets.Label(label="Tema", css_classes=["qs-button-label"]),
            css_classes=["qs-button", "unset", "theme-cycle-btn"],
            on_click=lambda _: asyncio.create_task(self._cycle_theme()),
        )
        self._popover = Gtk.Popover()
        self._popover.add_css_class("theme-hint-popover")
        self._popover.set_has_arrow(True)
        self._popover.set_position(Gtk.PositionType.TOP)
        self._hint_label = Gtk.Label(margin_top=6, margin_bottom=6, margin_start=10, margin_end=10)
        self._hint_label.add_css_class("theme-hint-popover-label")
        self._popover.set_child(self._hint_label)
        self._popover.set_parent(self._button)

        event = widgets.EventBox(
            child=[self._button],
            css_classes=["rec-unset"],
            on_hover=lambda _: self._on_hover_enter(),
            on_hover_lost=lambda _: self._on_hover_leave(),
        )
        super().__init__(child=[event], css_classes=["theme-cycle-box"])

    def _on_hover_enter(self) -> None:
        if self._hover_timer_id is not None:
            GLib.source_remove(self._hover_timer_id)
        self._hover_timer_id = GLib.timeout_add(get_hover_hint_ms(), self._show_hint)

    def _show_hint(self) -> bool:
        self._hint_label.set_text(get_theme_label(user_options=user_options))
        self._popover.popup()
        self._hover_timer_id = None
        return False

    def _on_hover_leave(self) -> None:
        if self._hover_timer_id is not None:
            GLib.source_remove(self._hover_timer_id)
            self._hover_timer_id = None
        self._popover.popdown()

    async def _cycle_theme(self) -> None:
        current = get_active_theme_id(user_options)
        next_id = get_next_theme_id(current)
        user_options.theme.active = next_id
        script = _resolve_apply_theme_script()
        if script.is_file():
            await utils.exec_sh_async(f'"{script}" {next_id}')
        self._hint_label.set_text(get_theme_label(theme_id=next_id))


class HyprsunsetControl(widgets.Box):
    def __init__(self):
        state = self._load_state()
        self._active = bool(state.get("active", False))
        self._temp = snap_temperature(int(state.get("temperature", TEMP_MIN)))

        self._moon_btn = widgets.Button(
            child=widgets.Label(label=ICON_MOON, css_classes=["user-icon-glyph"]),
            css_classes=["qs-button", "unset", "user-night-btn"],
            on_click=lambda _: asyncio.create_task(self._toggle()),
        )
        self._arrow_btn = widgets.Button(
            child=widgets.Icon(image="pan-end-symbolic", pixel_size=16),
            css_classes=["user-night-arrow", "unset"],
            visible=self._active,
            on_click=lambda _: self._toggle_slider(),
        )
        self._scale = widgets.Scale(
            min=TEMP_MIN,
            max=TEMP_MAX,
            step=TEMP_STEP,
            value=self._temp,
            hexpand=True,
            css_classes=["material-slider", "user-night-scale"],
            on_change=lambda scale: asyncio.create_task(
                self._set_temperature(int(scale.value))
            ),
        )
        self._slider_revealer = widgets.Revealer(
            reveal_child=False,
            transition_type="slide_down",
            transition_duration=100,
            child=widgets.Box(
                css_classes=["user-night-slider-box"],
                child=[
                    widgets.Box(
                        hexpand=True,
                        child=[
                            widgets.Label(
                                label=ICON_WARM,
                                css_classes=["user-night-temp-icon", "user-night-warm"],
                            ),
                            self._scale,
                            widgets.Label(
                                label=ICON_COLD,
                                css_classes=["user-night-temp-icon", "user-night-cold"],
                            ),
                        ],
                    ),
                ],
            ),
        )
        self._control_box = widgets.Box(
            css_classes=["user-night-box"],
            child=[self._moon_btn, self._arrow_btn],
        )
        super().__init__(
            vertical=True,
            css_classes=["user-night-wrap"],
            child=[self._slider_revealer, self._control_box],
        )
        self._sync_ui()
        GLib.timeout_add(500, self._poll_state)

    @staticmethod
    def _load_state() -> dict:
        if not HYPRSUNSET_STATE.is_file():
            return {"active": False, "temperature": TEMP_MIN}
        try:
            with open(HYPRSUNSET_STATE) as f:
                return json.load(f)
        except (json.JSONDecodeError, OSError):
            return {"active": False, "temperature": TEMP_MIN}

    def _sync_ui(self) -> None:
        if self._active:
            self._moon_btn.add_css_class("active")
            self._control_box.add_css_class("expanded")
            self._arrow_btn.visible = True
        else:
            self._moon_btn.remove_css_class("active")
            self._control_box.remove_css_class("expanded")
            self._arrow_btn.visible = False
            self._slider_revealer.reveal_child = False
            self._arrow_btn.remove_css_class("active")

    async def _run_script(self, name: str, *args: str) -> None:
        script = HYPRSUNSET_SCRIPTS / name
        if not script.is_file():
            script = Path(__file__).resolve().parents[4] / "scripts" / name
        if script.is_file():
            arg_str = " ".join(str(a) for a in args)
            await utils.exec_sh_async(f'"{script}" {arg_str}'.strip())

    async def _toggle(self) -> None:
        if self._active:
            await self._run_script("hyprsunset-off.sh")
            self._active = False
        else:
            await self._run_script("hyprsunset-on.sh", str(TEMP_MIN))
            self._active = True
            self._temp = TEMP_MIN
            self._scale.value = TEMP_MIN
        self._sync_ui()

    def _toggle_slider(self) -> None:
        self._slider_revealer.reveal_child = not self._slider_revealer.reveal_child
        if self._slider_revealer.reveal_child:
            self._arrow_btn.add_css_class("active")
            self._arrow_btn.child.icon_name = "pan-down-symbolic"
        else:
            self._arrow_btn.remove_css_class("active")
            self._arrow_btn.child.icon_name = "pan-end-symbolic"

    async def _set_temperature(self, temp: int) -> None:
        temp = snap_temperature(temp)
        if self._scale.value != temp:
            self._scale.value = temp
        self._temp = temp
        await self._run_script("hyprsunset-set-temp.sh", str(temp))

    def _poll_state(self) -> bool:
        state = self._load_state()
        active = bool(state.get("active", False))
        temp = snap_temperature(int(state.get("temperature", TEMP_MIN)))
        if active != self._active or temp != self._temp:
            self._active = active
            self._temp = temp
            self._scale.value = temp
            self._sync_ui()
        return True


class WallpaperMenu(Menu):
    def __init__(self, on_select, name: str, **kwargs):
        self._on_select = on_select
        super().__init__(
            name=name,
            transition_type="slide_up",
            vertical=False,
            child=[
                widgets.Button(
                    css_classes=["user-settings-menu-item", "unset"],
                    on_click=self._open_video_picker,
                    child=widgets.Box(
                        child=[
                            widgets.Icon(image="folder-videos-symbolic"),
                            widgets.Label(
                                label="Fondos de video",
                                halign="start",
                                css_classes=["user-settings-menu-label"],
                            ),
                        ]
                    ),
                ),
                widgets.Button(
                    css_classes=["user-settings-menu-item", "unset"],
                    on_click=self._open_image_picker,
                    child=widgets.Box(
                        child=[
                            widgets.Icon(image="image-x-generic-symbolic"),
                            widgets.Label(
                                label="Fondos de imagen",
                                halign="start",
                                css_classes=["user-settings-menu-label"],
                            ),
                        ]
                    ),
                ),
                widgets.Button(
                    css_classes=["user-settings-menu-item", "user-settings-menu-red", "unset"],
                    on_click=self._open_other_image_picker,
                    child=widgets.Box(
                        child=[
                            widgets.Icon(image="image-x-generic-symbolic"),
                            widgets.Label(
                                label="Otros fondos",
                                halign="start",
                                css_classes=["user-settings-menu-label"],
                            ),
                        ]
                    ),
                ),
            ],
            **kwargs,
        )

    def _open_video_picker(self, _) -> None:
        toggle_wallpaper_picker()
        self._on_select()

    def _open_image_picker(self, _) -> None:
        toggle_image_wallpaper_picker()
        self._on_select()

    def _open_other_image_picker(self, _) -> None:
        toggle_other_image_wallpaper_picker()
        self._on_select()


class User(widgets.Box):
    def __init__(self):
        user_image = widgets.Picture(
            image=user_options.user.bind(
                "avatar",
                lambda value: "user-info" if not os.path.exists(value) else value,
            ),
            width=44,
            height=44,
            content_fit="cover",
            style="border-radius: 10rem;",
        )

        username = widgets.Box(
            child=[
                widgets.Label(
                    label=os.getenv("USER"), css_classes=["user-name"], halign="start"
                ),
                widgets.Label(
                    label=utils.Poll(
                        timeout=60 * 1000, callback=lambda x: fetch.uptime
                    ).bind("output", lambda value: format_uptime(value)),
                    halign="start",
                    css_classes=["user-name-secondary"],
                ),
            ],
            vertical=True,
            css_classes=["user-name-box"],
        )

        user_info = widgets.EventBox(
            child=[widgets.Box(child=[user_image, username])],
            css_classes=["user-info-click", "rec-unset"],
            on_click=lambda x: asyncio.create_task(
                utils.exec_sh_async(
                    'foot -T ignis-fastfetch -e bash -c "fastfetch; read"'
                )
            ),
        )

        wallpaper_button = QSButton(
            label="Fondos",
            icon_name="display-symbolic",
            hexpand=False,
        )

        wallpaper_menu_instance = WallpaperMenu(
            name="wallpaper-picker",
            on_select=lambda: wallpaper_menu_instance.toggle(),
        )

        def toggle_wallpaper_menu(_):
            wallpaper_menu_instance.toggle()
            if wallpaper_menu_instance.reveal_child:
                wallpaper_button.add_css_class("active")
            else:
                wallpaper_button.remove_css_class("active")

        wallpaper_button.on_click = toggle_wallpaper_menu
        wallpaper_button.menu = wallpaper_menu_instance

        theme_button = ThemeCycleButton()
        hyprsunset_control = HyprsunsetControl()

        power_button = widgets.Button(
            child=widgets.Icon(image="system-shutdown-symbolic", pixel_size=20),
            css_classes=["user-power", "unset"],
            on_click=lambda x: toggle_power_menu(),
        )

        button_group = widgets.Box(
            halign="end",
            hexpand=True,
            spacing=2,
            css_classes=["user-button-group"],
            child=[
                theme_button,
                hyprsunset_control,
                wallpaper_button,
                power_button,
            ],
        )

        header = widgets.Box(
            hexpand=True,
            child=[user_info, button_group],
        )

        main_box = widgets.Box(
            vertical=True,
            hexpand=True,
            child=[
                header,
                wallpaper_menu_instance,
            ],
        )

        super().__init__(
            child=[main_box],
            css_classes=["user"],
        )
