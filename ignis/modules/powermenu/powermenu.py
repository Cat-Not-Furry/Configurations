import asyncio
import os
import platform
import shlex
import shutil
from ignis import widgets, utils
from ignis.window_manager import WindowManager

window_manager = WindowManager.get_default()

KEXEC_SCRIPT = os.path.join(utils.get_current_dir(), "scripts/kexec-action.sh")

KEXEC_ACTIONS = {
    "load": {
        "tile_label": "Cargar\nkernel",
        "icon": "drive-harddisk-symbolic",
        "action_desc": "cargar kernel en memoria (kexec -l)",
    },
    "exec": {
        "tile_label": "Ejecutar\nsalto",
        "icon": "media-skip-forward-symbolic",
        "action_desc": "ejecutar salto al kernel cargado (kexec -e)",
    },
    "full": {
        "tile_label": "Reinicio\nrápido",
        "icon": "system-reboot-symbolic",
        "action_desc": "reinicio rápido (cargar y saltar)",
    },
}


def _kernel_pkg() -> str:
    kver = platform.release()
    if "-lts" in kver:
        return "linux-lts"
    if "-zen" in kver:
        return "linux-zen"
    if "-hardened" in kver:
        return "linux-hardened"
    return "linux"


async def _confirm_and_run(title: str, message: str, command: str) -> None:
    _close_power_menu()
    if shutil.which("zenity"):
        proc = await asyncio.create_subprocess_exec(
            "zenity",
            "--question",
            "--title",
            title,
            "--text",
            message,
            stdout=asyncio.subprocess.PIPE,
            stderr=asyncio.subprocess.DEVNULL,
        )
        await proc.wait()
        if proc.returncode == 0:
            await utils.exec_sh_async(command)
    else:
        await utils.exec_sh_async(command)


def _power_button(label: str, icon: str, on_click) -> widgets.Button:
    return widgets.Button(
        css_classes=["powermenu-button", "unset"],
        on_click=on_click,
        child=widgets.Box(
            vertical=True,
            css_classes=["powermenu-button-box"],
            child=[
                widgets.Icon(icon_name=icon, pixel_size=32),
                widgets.Label(label=label, css_classes=["powermenu-button-label"]),
            ],
        ),
    )


def _close_power_menu() -> None:
    window_manager.get_window("ignis_POWERMENU").visible = False


def _launch_kexec_foot(mode: str) -> None:
    _close_power_menu()
    script = shlex.quote(KEXEC_SCRIPT)
    asyncio.create_task(
        utils.exec_sh_async(
            f"foot -e bash {script} {shlex.quote(mode)} --no-prompt"
        )
    )


def _kexec_tile(mode: str, on_select) -> widgets.Button:
    info = KEXEC_ACTIONS[mode]
    return widgets.Button(
        css_classes=["powermenu-kexec-tile", "unset"],
        on_click=lambda _: on_select(mode),
        child=widgets.Box(
            vertical=True,
            css_classes=["powermenu-kexec-tile-box"],
            child=[
                widgets.Icon(icon_name=info["icon"], pixel_size=36),
                widgets.Label(
                    label=info["tile_label"],
                    css_classes=["powermenu-kexec-tile-label"],
                    justify="center",
                ),
            ],
        ),
    )


class PowerMenu(widgets.RevealerWindow):
    def __init__(self):
        self._pending_kexec_mode: str | None = None
        self._confirm_label = widgets.Label(
            label="",
            css_classes=["powermenu-kexec-confirm-text"],
            justify="center",
            wrap=True,
            max_width_chars=40,
        )

        self._main_view = self._build_main_view()
        self._kexec_view = self._build_kexec_view()
        self._confirm_view = self._build_confirm_view()

        self._view_container = widgets.Box(
            child=[self._main_view, self._kexec_view, self._confirm_view],
        )
        self._show_view("main")

        menu = widgets.Box(
            vertical=True,
            css_classes=["powermenu", "rec-unset"],
            halign="center",
            valign="center",
            child=[self._view_container],
        )

        revealer = widgets.Revealer(
            transition_type="crossfade",
            reveal_child=True,
            child=menu,
            transition_duration=200,
        )

        super().__init__(
            visible=False,
            popup=True,
            kb_mode="on_demand",
            layer="overlay",
            css_classes=["unset"],
            anchor=["top", "right", "bottom", "left"],
            namespace="ignis_POWERMENU",
            child=widgets.Box(
                hexpand=True,
                vexpand=True,
                child=[
                    widgets.EventBox(
                        hexpand=True,
                        vexpand=True,
                        css_classes=["powermenu-overlay"],
                        on_click=lambda x: self._on_overlay_click(),
                    ),
                    widgets.Box(
                        hexpand=False,
                        vexpand=False,
                        halign="center",
                        valign="center",
                        child=[revealer],
                    ),
                    widgets.EventBox(
                        hexpand=True,
                        vexpand=True,
                        css_classes=["powermenu-overlay"],
                        on_click=lambda x: self._on_overlay_click(),
                    ),
                ],
            ),
            revealer=revealer,
            setup=lambda self: self.connect(
                "notify::visible",
                lambda *_: self._show_view("main") if self.visible else None,
            ),
        )

    def _on_overlay_click(self) -> None:
        self.visible = False

    def _show_view(self, name: str) -> None:
        views = {
            "main": self._main_view,
            "kexec": self._kexec_view,
            "confirm": self._confirm_view,
        }
        for view_name, view in views.items():
            view.visible = view_name == name

    def _build_main_view(self) -> widgets.Box:
        return widgets.Box(
            css_classes=["powermenu-button-box"],
            child=[
                _power_button(
                    "Bloquear",
                    "system-lock-screen-symbolic",
                    lambda x: asyncio.create_task(_run_and_close("hyprlock")),
                ),
                _power_button(
                    "Suspender",
                    "system-suspend-symbolic",
                    lambda x: asyncio.create_task(
                        _run_and_close("systemctl suspend")
                    ),
                ),
                _power_button(
                    "Cerrar sesión",
                    "system-log-out-symbolic",
                    lambda x: asyncio.create_task(
                        _confirm_and_run(
                            "Cerrar sesión",
                            "¿Salir de Hyprland?",
                            "hyprctl dispatch exit",
                        )
                    ),
                ),
                _power_button(
                    "Reiniciar",
                    "system-reboot-symbolic",
                    lambda x: asyncio.create_task(
                        _confirm_and_run(
                            "Reiniciar",
                            "¿Reiniciar el sistema?",
                            "systemctl reboot",
                        )
                    ),
                ),
                _power_button(
                    "Apagar",
                    "system-shutdown-symbolic",
                    lambda x: asyncio.create_task(
                        _confirm_and_run(
                            "Apagar",
                            "¿Apagar el sistema?",
                            "systemctl poweroff",
                        )
                    ),
                ),
                _power_button(
                    "Más",
                    "view-more-symbolic",
                    lambda x: self._show_view("kexec"),
                ),
            ],
        )

    def _build_kexec_view(self) -> widgets.Box:
        return widgets.Box(
            vertical=True,
            css_classes=["powermenu-kexec-view"],
            visible=False,
            child=[
                widgets.Box(
                    css_classes=["powermenu-kexec-tiles"],
                    child=[
                        _kexec_tile("load", self._on_kexec_tile_select),
                        _kexec_tile("exec", self._on_kexec_tile_select),
                        _kexec_tile("full", self._on_kexec_tile_select),
                    ],
                ),
                widgets.Button(
                    css_classes=["powermenu-view-back", "unset"],
                    on_click=lambda _: self._show_view("main"),
                    child=widgets.Label(label="Atrás"),
                ),
            ],
        )

    def _build_confirm_view(self) -> widgets.Box:
        return widgets.Box(
            vertical=True,
            css_classes=["powermenu-kexec-confirm"],
            visible=False,
            child=[
                self._confirm_label,
                widgets.Box(
                    spacing=12,
                    halign="center",
                    css_classes=["powermenu-kexec-confirm-actions"],
                    child=[
                        widgets.Button(
                            css_classes=["powermenu-kexec-confirm-btn", "unset"],
                            on_click=lambda _: self._on_kexec_confirm(),
                            child=widgets.Label(label="Confirmar"),
                        ),
                        widgets.Button(
                            css_classes=["powermenu-view-back", "unset"],
                            on_click=lambda _: self._show_view("kexec"),
                            child=widgets.Label(label="Cancelar"),
                        ),
                    ],
                ),
            ],
        )

    def _on_kexec_tile_select(self, mode: str) -> None:
        self._pending_kexec_mode = mode
        kver = platform.release()
        pkg = _kernel_pkg()
        action_desc = KEXEC_ACTIONS[mode]["action_desc"]
        self._confirm_label.label = (
            f"ADVERTENCIA: {action_desc}.\n\n"
            f"Se pierde trabajo no guardado.\n\n"
            f"Kernel: {kver}\n"
            f"Paquete: {pkg}"
        )
        self._show_view("confirm")

    def _on_kexec_confirm(self) -> None:
        if self._pending_kexec_mode:
            _launch_kexec_foot(self._pending_kexec_mode)
        self._pending_kexec_mode = None


async def _run_and_close(command: str) -> None:
    _close_power_menu()
    await utils.exec_sh_async(command)


def toggle_power_menu() -> None:
    window = window_manager.get_window("ignis_POWERMENU")
    window.visible = not window.visible
