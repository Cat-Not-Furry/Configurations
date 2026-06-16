import asyncio
import os
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

fetch = FetchService.get_default()


def format_uptime(value: tuple[int, int, int, int]) -> str:
    days, hours, minutes, seconds = value
    if days:
        return f"encendido {days:02}:{hours:02}:{minutes:02}"
    else:
        return f"encendido {hours:02}:{minutes:02}"


class WallpaperMenu(Menu):
    # MODIFICACIÓN: Aceptar 'name' y **kwargs
    def __init__(self, on_select, name: str, **kwargs):
        self._on_select = on_select
        super().__init__(
            name=name, # Pasar 'name' al constructor de la clase base
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
            **kwargs, # Pasar cualquier otro argumento al constructor de la clase base
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
                utils.exec_sh_async('foot -e bash -c "fastfetch; read"')
            ),
        )

        wallpaper_button = QSButton(
            label="Fondos",
            icon_name="display-symbolic",
            # Aquí pasamos directamente la instancia de WallpaperMenu
            # El QSButton usará su 'menu.bind("reveal_child")' para la flecha
        )

        # WallpaperMenu ya es un Revealer que contiene un Box con los 3 botones.
        # Quitamos el Revealer externo (`wallpaper_revealer`)
        wallpaper_menu_instance = WallpaperMenu(
            name="wallpaper-picker", # Ahora esto será aceptado por WallpaperMenu.__init__
            on_select=lambda: wallpaper_menu_instance.toggle() # Oculta el menú al seleccionar
        )

        # --- MODIFICACIÓN CLAVE: Lógica de click del botón padre ---
        # El botón padre debe togglear directamente la visibilidad del WallpaperMenu
        def toggle_wallpaper_menu(_):
            # Usamos el método toggle del Menu (que internamente actualiza opened_menu.value)
            # Esto asegurará que el reveal_child del WallpaperMenu se actualice.
            wallpaper_menu_instance.toggle()
            #print(f"DEBUG: Toggling WallpaperMenu. Reveal state: {wallpaper_menu_instance.reveal_child}")

            # Actualizar el estado 'active' del QSButton para CSS
            if wallpaper_menu_instance.reveal_child:
                wallpaper_button.add_css_class("active")
            else:
                wallpaper_button.remove_css_class("active")


        wallpaper_button.on_click = toggle_wallpaper_menu
        # wallpaper_button.on_activate = ... # REMOVED
        # wallpaper_button.on_deactivate = ... # REMOVED
        # wallpaper_button.active = ... # REMOVED (gestionado manualmente para el QSButton)
        wallpaper_button.menu = wallpaper_menu_instance # Pasamos la instancia de Menu al QSButton
        power_button = widgets.Button(
            child=widgets.Icon(image="system-shutdown-symbolic", pixel_size=20),
            css_classes=["user-power", "unset"],
            on_click=lambda x: toggle_power_menu(),
        )

        button_group = widgets.Box(
            halign="end",
            hexpand=True,
            child=[
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
                wallpaper_menu_instance, # <-- Ahora el WallpaperMenu (que es un Revealer) está directamente aquí
            ],
        )

        super().__init__(
            child=[main_box],
            css_classes=["user"],
        )


