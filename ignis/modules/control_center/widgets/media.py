import asyncio
from gi.repository import GLib  # type: ignore
from ignis import widgets
from ignis.services.mpris import MprisService, MprisPlayer

ALLOWED_PLAYERS = {
    "mpv", "strawberry", "parole", "vlc", "cmus",
    "brave", "firefox", "chromium", "google-chrome", "chrome",
    "vivaldi", "microsoft-edge", "opera",
}
BLOCKED_PLAYERS = {"spotify"}
LOOP_STATES = ["None", "Track", "Playlist"]

mpris = MprisService.get_default()


def _normalize(value: str | None) -> str:
    if not value:
        return ""
    return value.lower().replace(".desktop", "")


def is_allowed_player(player: MprisPlayer) -> bool:
    entry = _normalize(player.desktop_entry)
    identity = _normalize(player.identity)
    if any(blocked in entry or blocked in identity for blocked in BLOCKED_PLAYERS):
        return False
    return any(
        allowed in entry or allowed in identity for allowed in ALLOWED_PLAYERS
    )


def get_focused_player() -> MprisPlayer | None:
    allowed = [p for p in mpris.players if is_allowed_player(p)]
    if not allowed:
        return None
    for status in ("Playing", "Paused", "Stopped"):
        matches = [p for p in allowed if p.playback_status == status]
        if matches:
            return matches[-1]
    return allowed[-1]


async def toggle_playback(player: MprisPlayer) -> None:
    """Pause/Play explícito: PlayPause en navegadores suele ir a Stop y rompe el control."""
    status = player.playback_status or "Stopped"
    if status == "Playing":
        if player.can_pause:
            await player.pause_async()
        return
    if status == "Paused":
        if player.can_play:
            await player.play_async()
        return
    if player.can_play:
        await player.play_async()
        return
    await raise_player(player)


def format_time(seconds: int) -> str:
    if seconds is None or seconds < 0:
        return "0:00"
    minutes, secs = divmod(int(seconds), 60)
    return f"{minutes}:{secs:02d}"


def repeat_icon(loop_status: str | None) -> str:
    if loop_status == "Playlist":
        return "media-playlist-repeat-symbolic"
    if loop_status == "Track":
        return "media-playlist-repeat-song-symbolic"
    return "media-playlist-repeat-symbolic"


async def toggle_loop(player: MprisPlayer) -> None:
    current = player.loop_status or "None"
    if current not in LOOP_STATES:
        current = "None"
    next_status = LOOP_STATES[(LOOP_STATES.index(current) + 1) % len(LOOP_STATES)]
    await player._MprisPlayer__player_proxy.set_dbus_property_async(  # type: ignore[attr-defined]
        "LoopStatus", GLib.Variant("s", next_status)
    )


async def raise_player(player: MprisPlayer) -> None:
    await player._MprisPlayer__mpris_proxy.RaiseAsync()  # type: ignore[attr-defined]


def build_media_card(player: MprisPlayer) -> widgets.Box:
    art = widgets.Box(
        css_classes=["media-art"],
        halign="center",
        child=[
            widgets.Picture(
                image=player.bind("art_url"),
                width=255,
                height=255,
                content_fit="cover",
                visible=player.bind("art_url", lambda value: bool(value)),
            ),
            widgets.Icon(
                icon_name="folder-music-symbolic",
                pixel_size=72,
                visible=player.bind("art_url", lambda value: not bool(value)),
            ),
        ],
    )

    return widgets.Box(
        vertical=True,
        css_classes=["media-card", "rec-unset"],
        child=[
            art,
            widgets.Label(
                label=player.bind("title", lambda value: value or "Título desconocido"),
                ellipsize="end",
                max_width_chars=32,
                halign="center",
                css_classes=["media-title"],
            ),
            widgets.Label(
                label=player.bind("artist", lambda value: value or "Artista desconocido"),
                ellipsize="end",
                max_width_chars=32,
                halign="center",
                css_classes=["media-artist"],
            ),
            widgets.Box(
                css_classes=["media-times"],
                child=[
                    widgets.Label(
                        label=player.bind("position", format_time),
                        halign="start",
                        hexpand=True,
                    ),
                    widgets.Label(
                        label=player.bind("length", format_time),
                        halign="end",
                        hexpand=True,
                    ),
                ],
            ),
            widgets.Scale(
                value=player.bind("position"),
                max=player.bind("length"),
                hexpand=True,
                css_classes=["media-scale"],
                on_change=lambda x: asyncio.create_task(
                    player.set_position_async(int(x.value))
                ),
                visible=player.bind("length", lambda value: value is not None and value > 0),
            ),
            widgets.Box(
                css_classes=["media-controls"],
                halign="center",
                child=[
                    widgets.Button(
                        child=widgets.Icon(
                            image=player.bind("loop_status", repeat_icon),
                            pixel_size=18,
                        ),
                        css_classes=player.bind(
                            "loop_status",
                            lambda value: ["media-btn", "active"]
                            if value in ("Track", "Playlist")
                            else ["media-btn"],
                        ),
                        on_click=lambda x: asyncio.create_task(toggle_loop(player)),
                        visible=player.bind("can_control"),
                    ),
                    widgets.Button(
                        child=widgets.Icon(
                            image="media-skip-backward-symbolic",
                            pixel_size=20,
                        ),
                        css_classes=["media-btn"],
                        on_click=lambda x: asyncio.create_task(player.previous_async()),
                        visible=player.bind("can_go_previous"),
                    ),
                    widgets.Button(
                        child=widgets.Icon(
                            image=player.bind(
                                "playback_status",
                                lambda value: "media-playback-pause-symbolic"
                                if value == "Playing"
                                else "media-playback-start-symbolic",
                            ),
                            pixel_size=28,
                        ),
                        css_classes=["media-play-btn"],
                        on_click=lambda x: asyncio.create_task(toggle_playback(player)),
                        visible=player.bind(
                            "playback_status",
                            lambda value: value in ("Playing", "Paused")
                            or player.can_play
                            or player.can_pause,
                        ),
                    ),
                    widgets.Button(
                        child=widgets.Icon(
                            image="media-skip-forward-symbolic",
                            pixel_size=20,
                        ),
                        css_classes=["media-btn"],
                        on_click=lambda x: asyncio.create_task(player.next_async()),
                        visible=player.bind("can_go_next"),
                    ),
                    widgets.Button(
                        child=widgets.Icon(
                            image="view-list-symbolic",
                            pixel_size=18,
                        ),
                        css_classes=["media-btn"],
                        on_click=lambda x: asyncio.create_task(raise_player(player)),
                        visible=player.bind("can_control"),
                    ),
                ],
            ),
        ],
    )


class Media(widgets.Box):
    def __init__(self):
        self._player_connections: dict[int, list] = {}
        self._card_box = widgets.Box(vertical=True, css_classes=["rec-unset"])

        super().__init__(
            vertical=True,
            visible=False,
            css_classes=["media-wrapper", "rec-unset"],
            child=[self._card_box],
            setup=self.__setup,
        )

    def __setup(self, *_args) -> None:
        mpris.connect("player_added", lambda _svc, player: self.__on_player_added(player))
        for player in mpris.players:
            self.__on_player_added(player)
        self.__refresh()

    def __on_player_added(self, player: MprisPlayer) -> None:
        if not is_allowed_player(player):
            return

        player_id = id(player)
        if player_id in self._player_connections:
            return

        handlers = [
            player.connect("notify::playback-status", lambda *_: self.__refresh()),
            player.connect("closed", lambda *_: self.__on_player_closed(player)),
        ]
        self._player_connections[player_id] = handlers
        self.__refresh()

    def __on_player_closed(self, player: MprisPlayer) -> None:
        player_id = id(player)
        for handler in self._player_connections.pop(player_id, []):
            try:
                player.disconnect(handler)
            except Exception:
                pass
        self.__refresh()

    def __refresh(self) -> None:
        player = get_focused_player()
        self._card_box.child = [] if player is None else [build_media_card(player)]
        self.visible = player is not None
