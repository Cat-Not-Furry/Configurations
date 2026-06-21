import asyncio
import json
import os
import shlex
import shutil
import subprocess
from pathlib import Path

from ignis import utils, widgets
from ignis.window_manager import WindowManager
from user_options import user_options

window_manager = WindowManager.get_default()

WALLPAPER_DIR = Path(user_options.wallpaperpicker.video_base_path)
IMAGE_WALLPAPER_DIR = Path(user_options.wallpaperpicker.image_base_path)
OTHER_IMAGE_WALLPAPER_DIR = Path(user_options.wallpaperpicker.other_image_base_path)
THUMB_CACHE = Path.home() / ".cache" / "ignis" / "wallpaper-thumbs"
VIDEO_EXTENSIONS = {".mp4", ".mkv", ".webm", ".mov"}
IMAGE_EXTENSIONS = {".png", ".jpg", ".jpeg", ".webp", ".bmp"}
COLUMNS = int(user_options.wallpaperpicker.picker_columns)


def _close_wallpaper_picker() -> None:
    window_manager.get_window("ignis_WALLPAPER_PICKER").visible = False


def _list_videos() -> list[Path]:
    # Try reading JSON first
    vids = _read_json("video")
    if vids:
        return vids

    if not WALLPAPER_DIR.is_dir():
        return []
    videos = [
        path
        for path in sorted(WALLPAPER_DIR.iterdir())
        if path.is_file() and path.suffix.lower() in VIDEO_EXTENSIONS
    ]
    return videos


def _list_images() -> list[Path]:
    imgs = _read_json("image")
    if imgs:
        return imgs

    if not IMAGE_WALLPAPER_DIR.is_dir():
        return []
    images = [
        path
        for path in sorted(IMAGE_WALLPAPER_DIR.iterdir())
        if path.is_file() and path.suffix.lower() in IMAGE_EXTENSIONS
    ]
    return images


def _list_other_images() -> list[Path]:
    imgs = _read_json("other_image")
    if imgs:
        return imgs

    if not OTHER_IMAGE_WALLPAPER_DIR.is_dir():
        return []
    images = [
        path
        for path in sorted(OTHER_IMAGE_WALLPAPER_DIR.iterdir())
        if path.is_file() and path.suffix.lower() in IMAGE_EXTENSIONS
    ]
    return images


def _read_json(mode: str) -> list[Path]:
    """Read a JSON file in ~/.config/ignis for the given mode.

    Expected format:
    {
      "ruta": "relative/or/absolute/base/path",
      "entries": {"name":"relative_path1","name2":"relative_path2"}
    }
    """
    cfg_dir = Path.home() / ".config" / "ignis" / "configs"
    filename = None
    if mode == "video":
        filename = "life-wallpapers.json"
    elif mode == "image":
        filename = "wallpapers.json"
    else:
        filename = "other-wallpapers.json"

    cfg_path = cfg_dir / filename
    if not cfg_path.is_file():
        return []

    try:
        with open(cfg_path, "r", encoding="utf-8") as f:
            data = json.load(f)
    except Exception:
        return []

    base = data.get("ruta")
    entries = data.get("entries") or {}
    result: list[Path] = []
    if not entries:
        return []

    # Resolve base path
    if base:
        base_path = Path(base)
        if not base_path.is_absolute():
            base_path = Path.home() / base_path
    else:
        # fallback to default bases
        if mode == "video":
            base_path = WALLPAPER_DIR
        elif mode == "image":
            base_path = IMAGE_WALLPAPER_DIR
        else:
            base_path = OTHER_IMAGE_WALLPAPER_DIR

    for k, v in entries.items():
        p = base_path / v
        if p.exists():
            result.append(p)

    return result


def _thumb_path(video: Path) -> Path:
    safe_name = video.name.replace("/", "_")
    return THUMB_CACHE / f"{safe_name}.jpg"


def _generate_thumb(video: Path, dest: Path) -> bool:
    if dest.exists():
        return True
    if not shutil.which("ffmpeg"):
        return False
    dest.parent.mkdir(parents=True, exist_ok=True)
    result = subprocess.run(
        [
            "ffmpeg",
            "-y",
            "-ss",
            "00:00:01",
            "-i",
            str(video),
            "-vframes",
            "1",
            "-q:v",
            "2",
            str(dest),
        ],
        capture_output=True,
        check=False,
    )
    return result.returncode == 0 and dest.exists()


def _apply_wallpaper(video: Path) -> None:
    quoted = shlex.quote(str(video))
    asyncio.create_task(
        utils.exec_sh_async(
            "killall mpvpaper 2>/dev/null; "
            f'mpvpaper -p -o "no-audio loop" eDP-1 {quoted} & '
            f'mpvpaper -p -o "no-audio loop" HDMI-A-2 {quoted} &'
        )
    )
    _close_wallpaper_picker()


def _apply_image_wallpaper(image: Path) -> None:
    quoted = shlex.quote(str(image))
    script = Path.home() / ".config/hypr/scripts/awww-wallpaper.sh"
    if not script.is_file():
        script = Path(__file__).resolve().parents[3] / "scripts" / "awww-wallpaper.sh"
    asyncio.create_task(
        utils.exec_sh_async(f'"{script}" {quoted} fade &')
    )
    _close_wallpaper_picker()


def _wallpaper_item(path: Path, mode: str) -> widgets.Button:
    if mode == "video":
        thumb = _thumb_path(path)
        has_thumb = _generate_thumb(path, thumb)

        if has_thumb:
            preview = widgets.Picture(
                image=str(thumb),
                width=360,
                height=140,
                content_fit="cover",
                style="border-radius: 0.5rem;",
            )
        else:
            preview = widgets.Icon(
                icon_name="video-x-generic-symbolic",
                pixel_size=48,
            )

        on_click = lambda _: _apply_wallpaper(path)
    else:
        preview = widgets.Picture(
            image=str(path),
            width=360,
            height=140,
            content_fit="cover",
            style="border-radius: 0.5rem;",
        )
        on_click = lambda _: _apply_image_wallpaper(path)

    return widgets.Button(
        css_classes=["wallpaper-picker-item", "unset"],
        on_click=on_click,
        child=widgets.Box(
            vertical=True,
            spacing=8,
            css_classes=["wallpaper-picker-item-box"],
            child=[
                preview,
                widgets.Label(
                    label=path.name,
                    ellipsize="middle",
                    max_width_chars=22,
                    css_classes=["wallpaper-picker-item-label"],
                ),
            ],
        ),
    )


def _build_grid(mode: str) -> widgets.Box:
    if mode == "video":
        items = _list_videos()
        source = WALLPAPER_DIR
    elif mode == "image":
        items = _list_images()
        source = IMAGE_WALLPAPER_DIR
    else:
        items = _list_other_images()
        source = OTHER_IMAGE_WALLPAPER_DIR

    if not items:
        return widgets.Box(
            css_classes=["wallpaper-picker-empty"],
            child=[
                widgets.Label(
                    label=f"Sin archivos en {source}",
                    css_classes=["wallpaper-picker-empty-label"],
                )
            ],
        )

    rows: list[widgets.Box] = []
    row_items: list[widgets.Button] = []

    for item in items:
        row_items.append(_wallpaper_item(item, mode))
        if len(row_items) >= COLUMNS:
            rows.append(widgets.Box(css_classes=["wallpaper-picker-row"], child=row_items))
            row_items = []

    if row_items:
        rows.append(widgets.Box(css_classes=["wallpaper-picker-row"], child=row_items))

    return widgets.Box(vertical=True, css_classes=["wallpaper-picker-grid"], child=rows)


class WallpaperPicker(widgets.RevealerWindow):
    def __init__(self):
        self._mode = "video"
        self._title_label = widgets.Label(
            label="Fondos de video",
            css_classes=["wallpaper-picker-title"],
        )
        grid = _build_grid(self._mode)
        self._scroll = widgets.Scroll(
            vexpand=True,
            child=grid,
            css_classes=["wallpaper-picker-scroll"],
        )

        self._grid_box = widgets.Box(
            vertical=True,
            css_classes=["wallpaper-picker-content"],
            style=f"min-width: {user_options.wallpaperpicker.picker_width}px; min-height: {user_options.wallpaperpicker.picker_height}px;",
            child=[
                self._title_label,
                self._scroll,
            ],
        )

        revealer = widgets.Revealer(
            transition_type="crossfade",
            reveal_child=True,
            child=self._grid_box,
            transition_duration=100,
        )

        super().__init__(
            visible=False,
            popup=True,
            kb_mode="on_demand",
            layer="overlay",
            css_classes=["unset"],
            anchor=["top", "right", "bottom", "left"],
            namespace="ignis_WALLPAPER_PICKER",
            child=widgets.Box(
                hexpand=True,
                vexpand=True,
                child=[
                    widgets.EventBox(
                        hexpand=True,
                        vexpand=True,
                        css_classes=["wallpaper-picker-overlay"],
                        on_click=lambda _: setattr(self, "visible", False),
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
                        css_classes=["wallpaper-picker-overlay"],
                        on_click=lambda _: setattr(self, "visible", False),
                    ),
                ],
            ),
            revealer=revealer,
            setup=lambda self: self.connect(
                "notify::visible",
                lambda *_: self._refresh_grid() if self.visible else None,
            ),
        )

    def _refresh_grid(self) -> None:
        self._scroll.set_child(_build_grid(self._mode))

    def _set_mode(self, mode: str) -> None:
        self._mode = mode
        if mode == "video":
            self._title_label.label = "Fondos de video"
        elif mode == "image":
            self._title_label.label = "Fondos de imagen"
        else:
            self._title_label.label = "Otros fondos"
        self._refresh_grid()


def _set_picker_mode(mode: str) -> None:
    window = window_manager.get_window("ignis_WALLPAPER_PICKER")
    if not window:
        return

    try:
        window._set_mode(mode)
    except AttributeError:
        pass


def toggle_wallpaper_picker() -> None:
    window = window_manager.get_window("ignis_WALLPAPER_PICKER")
    if not window:
        return

    current_mode = getattr(window, "_mode", None)
    if window.visible and current_mode == "video":
        window.visible = False
        return

    _set_picker_mode("video")
    window.visible = True


def toggle_image_wallpaper_picker() -> None:
    window = window_manager.get_window("ignis_WALLPAPER_PICKER")
    if not window:
        return

    current_mode = getattr(window, "_mode", None)
    if window.visible and current_mode == "image":
        window.visible = False
        return

    _set_picker_mode("image")
    window.visible = True


def toggle_other_image_wallpaper_picker() -> None:
    window = window_manager.get_window("ignis_WALLPAPER_PICKER")
    if not window:
        return

    current_mode = getattr(window, "_mode", None)
    if window.visible and current_mode == "other_image":
        window.visible = False
        return

    _set_picker_mode("other_image")
    window.visible = True
