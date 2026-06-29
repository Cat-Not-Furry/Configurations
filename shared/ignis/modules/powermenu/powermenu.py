import asyncio
import os
import platform
import shlex
from ignis import widgets, utils
from ignis.window_manager import WindowManager

window_manager = WindowManager.get_default()

KEXEC_SCRIPT = os.path.expanduser("~/.config/ignis/scripts/kexec-action.sh")
KEXEC_FOOT_TITLE = "ignis-kexec"

# Kernels instalados en este equipo (pares vmlinuz + initramfs en /boot).
KERNEL_PACKAGES = ("linux-lts", "linux-cnf")

KEXEC_ACTIONS = {
    "load": {
        "tile_label": "Cargar\nkernel",
        "icon": "drive-harddisk-symbolic",
    },
    "exec": {
        "tile_label": "Ejecutar\nsalto",
        "icon": "media-skip-forward-symbolic",
    },
    "full": {
        "tile_label": "Reinicio\nrápido",
        "icon": "system-reboot-symbolic",
    },
}


def _running_kernel_pkg() -> str:
    kver = platform.release()
    if "-lts" in kver:
        return "linux-lts"
    if "-cnf" in kver:
        return "linux-cnf"
    if "-zen" in kver:
        return "linux-zen"
    if "-hardened" in kver:
        return "linux-hardened"
    return "linux"


def _kernel_packages() -> list[tuple[str, bool]]:
    """Lista fija (nombre_paquete, es_actual) con archivos en /boot."""
    running = _running_kernel_pkg()
    found: list[tuple[str, bool]] = []
    for pkg in KERNEL_PACKAGES:
        vmlinuz = f"/boot/vmlinuz-{pkg}"
        initrd = f"/boot/initramfs-{pkg}.img"
        if os.path.isfile(vmlinuz) and os.path.isfile(initrd):
            found.append((pkg, pkg == running))
    return found


def _power_button(label: str, icon: str, on_click, css_classes=None) -> widgets.Button:
    classes = ["powermenu-button", "unset"]
    if css_classes:
        classes.extend(css_classes)
    return widgets.Button(
        css_classes=classes,
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


def _launch_kexec_foot(mode: str, pkg: str | None = None) -> None:
    _close_power_menu()
    script = shlex.quote(KEXEC_SCRIPT)
    mode_q = shlex.quote(mode)
    cmd = f"foot -T {shlex.quote(KEXEC_FOOT_TITLE)} -e bash {script} {mode_q}"
    if pkg:
        cmd += f" {shlex.quote(pkg)}"
    asyncio.create_task(utils.exec_sh_async(cmd))


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
        self._pending_confirm_command: str | None = None
        self._confirm_back_view = "main"

        self._confirm_title = widgets.Label(
            label="",
            css_classes=["powermenu-confirm-title"],
            justify="center",
        )
        self._confirm_label = widgets.Label(
            label="",
            css_classes=["powermenu-confirm-text"],
            justify="center",
            wrap=True,
            max_width_chars=40,
        )

        self._kernel_list_box = widgets.Box(
            vertical=True,
            spacing=4,
            css_classes=["powermenu-kernel-list"],
        )

        self._main_view = self._build_main_view()
        self._kexec_view = self._build_kexec_view()
        self._kernel_view = self._build_kernel_view()
        self._confirm_view = self._build_confirm_view()

        self._view_container = widgets.Box(
            child=[
                self._main_view,
                self._kexec_view,
                self._kernel_view,
                self._confirm_view,
            ],
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
            transition_duration=100,
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
            "kernels": self._kernel_view,
            "confirm": self._confirm_view,
        }
        for view_name, view in views.items():
            view.visible = view_name == name

    def _show_confirm(
        self,
        title: str,
        message: str,
        command: str,
        back_view: str = "main",
    ) -> None:
        self._pending_confirm_command = command
        self._confirm_back_view = back_view
        self._confirm_title.label = title
        self._confirm_label.label = message
        self._show_view("confirm")

    def _on_confirm_accept(self) -> None:
        cmd = self._pending_confirm_command
        self._pending_confirm_command = None
        if cmd:
            asyncio.create_task(_run_and_close(cmd))

    def _on_confirm_cancel(self) -> None:
        self._pending_confirm_command = None
        self._show_view(self._confirm_back_view)

    def _rebuild_kernel_list(self) -> None:
        self._kernel_list_box.child = []
        kernels = _kernel_packages()
        if not kernels:
            self._kernel_list_box.child = [
                widgets.Label(
                    label="No hay kernels con initramfs en /boot",
                    css_classes=["powermenu-kernel-empty"],
                )
            ]
            return

        items: list[widgets.Button] = []
        for pkg, is_running in kernels:
            label = f"● {pkg} (actual)" if is_running else pkg

            def on_pick(_btn, p=pkg):
                mode = self._pending_kexec_mode
                if mode:
                    _launch_kexec_foot(mode, p)
                self._pending_kexec_mode = None

            items.append(
                widgets.Button(
                    css_classes=[
                        "powermenu-kernel-item",
                        "unset",
                        *(
                            ["powermenu-kernel-item-current"]
                            if is_running
                            else []
                        ),
                    ],
                    hexpand=True,
                    on_click=on_pick,
                    child=widgets.Label(label=label, hexpand=True),
                )
            )
        self._kernel_list_box.child = items

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
                        _run_and_close("hyprctl dispatch exit")
                    ),
                ),
                _power_button(
                    "Reiniciar",
                    "system-reboot-symbolic",
                    lambda x: self._show_confirm(
                        "Reiniciar",
                        "¿Reiniciar el sistema?\nSe pierde trabajo no guardado.",
                        "systemctl reboot",
                    ),
                    css_classes=["powermenu-button-danger"],
                ),
                _power_button(
                    "Apagar",
                    "system-shutdown-symbolic",
                    lambda x: self._show_confirm(
                        "Apagar",
                        "¿Apagar el sistema?\nSe pierde trabajo no guardado.",
                        "systemctl poweroff",
                    ),
                    css_classes=["powermenu-button-danger"],
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

    def _build_kernel_view(self) -> widgets.Box:
        return widgets.Box(
            vertical=True,
            css_classes=["powermenu-kernel-view"],
            visible=False,
            child=[
                widgets.Label(
                    label="Elegir kernel",
                    css_classes=["powermenu-kernel-heading"],
                ),
                widgets.Scroll(
                    css_classes=["powermenu-kernel-scroll"],
                    child=self._kernel_list_box,
                ),
                widgets.Button(
                    css_classes=["powermenu-view-back", "unset"],
                    on_click=lambda _: self._show_view("kexec"),
                    child=widgets.Label(label="Atrás"),
                ),
            ],
        )

    def _build_confirm_view(self) -> widgets.Box:
        return widgets.Box(
            vertical=True,
            css_classes=["powermenu-confirm"],
            visible=False,
            child=[
                self._confirm_title,
                self._confirm_label,
                widgets.Box(
                    spacing=12,
                    halign="center",
                    css_classes=["powermenu-confirm-actions"],
                    child=[
                        widgets.Button(
                            css_classes=["powermenu-confirm-btn", "unset"],
                            on_click=lambda _: self._on_confirm_accept(),
                            child=widgets.Label(label="Confirmar"),
                        ),
                        widgets.Button(
                            css_classes=["powermenu-view-back", "unset"],
                            on_click=lambda _: self._on_confirm_cancel(),
                            child=widgets.Label(label="Cancelar"),
                        ),
                    ],
                ),
            ],
        )

    def _on_kexec_tile_select(self, mode: str) -> None:
        if mode == "exec":
            _launch_kexec_foot("exec")
            return
        self._pending_kexec_mode = mode
        self._rebuild_kernel_list()
        self._show_view("kernels")


async def _run_and_close(command: str) -> None:
    _close_power_menu()
    await utils.exec_sh_async(command)


def toggle_power_menu() -> None:
    window = window_manager.get_window("ignis_POWERMENU")
    window.visible = not window.visible
