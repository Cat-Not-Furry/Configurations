import asyncio
from gi.repository import GObject  # type: ignore
from typing import Callable
from ignis.gobject import Binding
from .menu import Menu
from ignis import widgets # Asegurarse de que widgets está importado

class QSButton(widgets.Button):
    def __init__(
        self,
        label: str | Binding,
        icon_name: str | Binding,
        on_activate: Callable | None = None,
        on_deactivate: Callable | None = None,
        menu: Menu | None = None,
        **kwargs,
    ):
        self.on_activate = on_activate
        self.on_deactivate = on_deactivate
        self._active = False # Esto es para la clase CSS 'active'
        self._menu = menu

        # --- MODIFICACIÓN: Usar un Icono para la flecha en lugar de Arrow ---
        self._arrow_icon_widget = None # Renombrado para evitar conflictos
        if menu:
            self._arrow_icon_widget = widgets.Icon(
                icon_name="pan-end-symbolic",
                halign="end",
                hexpand=True,
                pixel_size=16,
            )
            # Conectar la flecha al estado del menú
            menu.connect("notify::reveal-child", self._update_arrow_icon_state)
        # --- FIN MODIFICACIÓN ---

        hexpand = kwargs.pop("hexpand", True)

        super().__init__(
            child=widgets.Box(
                child=[
                    widgets.Icon(image=icon_name),
                    widgets.Label(label=label, css_classes=["qs-button-label"]),
                    self._arrow_icon_widget, # Usar el nuevo icono de flecha
                ]
            ),
            on_click=self.__callback,
            css_classes=["qs-button", "unset"],
            hexpand=hexpand,
            **kwargs,
        )
    
    # --- NUEVO MÉTODO: Para actualizar el icono de la flecha ---
    def _update_arrow_icon_state(self, menu, _): # Renombrado
        if self._arrow_icon_widget: # Asegurarse de que el icono existe
            if menu.reveal_child:
                self._arrow_icon_widget.set_icon_name("pan-down-symbolic")
            else:
                self._arrow_icon_widget.set_icon_name("pan-end-symbolic")

    def __callback(self, *args) -> None:
        if self._menu:
            self._menu.toggle()
        
        # Para compatibilidad con el sistema de `active` de QSButton
        # vamos a actualizarlo aquí.
        if self._menu:
            self.active = self._menu.reveal_child
        else: # Si no hay menú, usa la lógica original del active/deactive
            if self.active:
                if self.on_deactivate:
                    self.on_deactivate(self)
            else:
                if self.on_activate:
                    self.on_activate(self)

    @GObject.Property
    def active(self) -> bool:
        return self._active

    @active.setter
    def active(self, value: bool) -> None:
        self._active = value
        if value:
            self.add_css_class("active")
        else:
            self.remove_css_class("active")

    @GObject.Property
    def menu(self) -> Menu | None:
        return self._menu
    
    @menu.setter
    def menu(self, value: Menu | None) -> None:
        self._menu = value
        if value and self._arrow_icon_widget: # Usar el nuevo nombre
            value.connect("notify::reveal-child", self._update_arrow_icon_state)
            self._update_arrow_icon_state(value, None)
            self.active = value.reveal_child
