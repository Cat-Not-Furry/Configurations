import os
from ignis import utils
from modules import (
    ControlCenter,
    Launcher,
    OSD,
    PowerMenu,
    WallpaperPicker,
)
from modules.theme_loader import get_theme_ignis_colors
from ignis.css_manager import CssManager, CssInfoPath
from ignis.icon_manager import IconManager
from user_options import user_options

icon_manager = IconManager.get_default()
css_manager = CssManager.get_default()


def format_scss_var(name: str, val: str) -> str:
    return f"${name}: {val};\n"


def patch_style_scss(path: str) -> str:
    with open(path) as file:
        contents = file.read()

    if user_options.material.colors:
        scss_colors = "".join(
            format_scss_var(key, value)
            for key, value in user_options.material.colors.items()
        )
    else:
        theme_colors = get_theme_ignis_colors(user_options)
        if theme_colors:
            scss_colors = "".join(
                format_scss_var(key, value) for key, value in theme_colors.items()
            )
        else:
            defaults_path = os.path.join(
                utils.get_current_dir(), "scss/default_colors.scss"
            )
            with open(defaults_path) as file:
                scss_colors = file.read()

    string = (
        format_scss_var("darkmode", str(user_options.material.dark_mode).lower())
        + scss_colors
        + contents
    )

    return utils.sass_compile(
        string=string, extra_args=["--load-path", utils.get_current_dir()]
    )


css_manager.apply_css(
    CssInfoPath(
        name="main",
        path=os.path.join(utils.get_current_dir(), "style.scss"),
        compiler_function=patch_style_scss,
    )
)

icon_manager.add_icons(os.path.join(utils.get_current_dir(), "icons"))

ControlCenter()
Launcher()
OSD()
PowerMenu()
WallpaperPicker()
