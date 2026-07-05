import os
from ignis.options_manager import OptionsGroup, OptionsManager
from ignis import DATA_DIR, CACHE_DIR  # type: ignore

USER_OPTIONS_FILE = f"{DATA_DIR}/user_options.json"
OLD_USER_OPTIONS_FILE = f"{CACHE_DIR}/user_options.json"


# FIXME: remove someday
def _migrate_old_options_file() -> None:
    with open(OLD_USER_OPTIONS_FILE) as f:
        data = f.read()

    with open(USER_OPTIONS_FILE, "w") as f:
        f.write(data)


class UserOptions(OptionsManager):
    def __init__(self):
        if not os.path.exists(USER_OPTIONS_FILE) and os.path.exists(
            OLD_USER_OPTIONS_FILE
        ):
            _migrate_old_options_file()

        try:
            super().__init__(file=USER_OPTIONS_FILE)
        except FileNotFoundError:
            pass

    class User(OptionsGroup):
        avatar: str = f"{os.path.expanduser('~')}/.config/ignis/icons/profile/user.jpeg"
    class Settings(OptionsGroup):
        last_page: int = 0

    class Material(OptionsGroup):
        dark_mode: bool = True
        colors: dict[str, str] = {}

    class Theme(OptionsGroup):
        active: str = "blue"

    class Bar(OptionsGroup):
        position: str = "top"
        height: int = 26

    class WallpaperPicker(OptionsGroup):
        video_base_path: str = f"{os.path.expanduser('~')}/Videos/Wallpapers"
        image_base_path: str = f"{os.path.expanduser('~')}/.config/fondos"
        other_image_base_path: str = f"{os.path.expanduser('~')}/.config/fondos/other"
        picker_width: int = 1200
        picker_height: int = 600
        picker_columns: int = 3

    user = User()
    settings = Settings()
    material = Material()
    theme = Theme()
    bar = Bar()
    wallpaperpicker = WallpaperPicker()


user_options = UserOptions()
