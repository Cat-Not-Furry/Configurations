/* themes.h */
#ifndef THEMES_H
#define THEMES_H

struct Theme {
  const char *inactive;
  const char *active;
  const char *bg;
  const char *focus;
};

static const struct Theme material = {
    .inactive = "#4c566a",
    .active = "#1e1e2e",
    .bg = "#0f101a",
    .focus = "#e2e4e5",
};

static const struct Theme onedark = {
    .inactive = "#4c566a",
    .active = "#222222",
    .bg = "#1e2127",
    .focus = "#E06C75",
};

static const struct Theme nord = {
    .inactive = "#4c566a",
    .active = "#222222",
    .bg = "#2e3440",
    .focus = "#81a1c1",
};

static const struct Theme monokai_pro = {
    .inactive = "#727072",
    .active = "#2d2a2e",
    .bg = "#2d2a2e",
    .focus = "#a9dc76",
};

static const struct Theme gruvbox = {
    .inactive = "#928374",
    .active = "#fbf1c7",
    .bg = "#282828",
    .focus = "#83a598",
};

static const struct Theme solarized_dark = {
    .inactive = "#657b83",
    .active = "#93a1a1",
    .bg = "#002b36",
    .focus = "#b58900",
};

static const struct Theme dracula = {
    .inactive = "#6272a4",
    .active = "#f8f8f2",
    .bg = "#282a36",
    .focus = "#ff79c6",
};

static const struct Theme tomorrow_night = {
    .inactive = "#4d4d4c",
    .active = "#222222",
    .bg = "#1d1f21",
    .focus = "#cc6666",
};

static const char window_border[] = "#000000";

static const char *colors[][3] = {
    // Tema Material
    {material.inactive, material.bg, window_border},
    {material.active, material.focus, material.focus},

    // Tema Dracula
    {dracula.inactive, dracula.bg, window_border},
    {dracula.active, dracula.focus, dracula.focus},

    // Tema Nord
    {nord.inactive, nord.bg, window_border},
    {nord.active, nord.focus, nord.focus},

    // Tema Monokai Pro
    {monokai_pro.inactive, monokai_pro.bg, window_border},
    {monokai_pro.active, monokai_pro.focus, monokai_pro.focus},

    // Tema Onedark
    {onedark.inactive, onedark.bg, window_border},
    {onedark.active, onedark.focus, onedark.focus},

    // Tema Gruvbox
    {gruvbox.inactive, gruvbox.bg, window_border},
    {gruvbox.active, gruvbox.focus, gruvbox.focus},

    // Tema Solarized Dark
    {solarized_dark.inactive, solarized_dark.bg, window_border},
    {solarized_dark.active, solarized_dark.focus, solarized_dark.focus},

    // Tema Tomorrow Night
    {tomorrow_night.inactive, tomorrow_night.bg, window_border},
    {tomorrow_night.active, tomorrow_night.focus, tomorrow_night.focus},
};

#endif /* THEMES_H */
