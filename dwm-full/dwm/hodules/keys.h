/* keys.h */
#ifndef KEYS_H
#define KEYS_H

#include <X11/XF86keysym.h>

#define TAGKEYS(KEY, TAG)                                                      \
  {MODKEY, KEY, view, {.ui = 1 << TAG}},                                       \
      {MODKEY | ControlMask, KEY, toggleview, {.ui = 1 << TAG}},               \
      {MODKEY | ShiftMask, KEY, tag, {.ui = 1 << TAG}},                        \
      {MODKEY | ControlMask | ShiftMask, KEY, toggletag, {.ui = 1 << TAG}},

#define STATUSBAR "dwmblocks"

// Helper for spawning shell commands
#define SHCMD(cmd)                                                             \
  {                                                                            \
    .v = (const char *[]) { "/bin/sh", "-c", cmd, NULL }                       \
  }

/* commands */
static char *dmenucmd[] = {"dmenu_run"};
static char dmenumon[2] = "0";

static char *screenshot[] = {
    "flameshot", "screen", "--path", NULL, NULL,
};

static const Key keys[] = {
    /* modifier                     key        function        argument */
    {MODKEY, XK_d, spawn, SHCMD("dmenu_run")},
    {MODKEY, XK_r, spawn, SHCMD("i3-dmenu-desktop")},
    {MODKEY | ShiftMask, XK_d, spawn, SHCMD("rofi -show drun -show-icons")},
    {MODKEY, XK_t, spawn, SHCMD("st")},
    //{MODKEY, XK_f, spawn, SHCMD("firefox")},

    /* volume control */
    {0, XF86XK_AudioRaiseVolume, spawn,
     SHCMD("pactl set-sink-volume @DEFAULT_SINK@ +2%")},
    {0, XF86XK_AudioLowerVolume, spawn,
     SHCMD("pactl set-sink-volume @DEFAULT_SINK@ -2%")},
    {0, XF86XK_AudioMute, spawn,
     SHCMD("pactl set-sink-mute @DEFAULT_SINK@ toggle")},
    {0, XK_Print, spawn, SHCMD("shotgun")},
    {MODKEY, XK_Print, spawn, SHCMD("kazam")},
    
    /* Brightness control */
    { 0, XF86XK_MonBrightnessUp,   spawn, SHCMD("brightnessctl set +2%") },
    { 0, XF86XK_MonBrightnessDown, spawn, SHCMD("brightnessctl set 2%-") },

    {MODKEY, XK_e, spawn, SHCMD("thunar")},
    {MODKEY, XK_f, spawn, SHCMD("barve")},
    {MODKEY, XK_b, togglebar, {0}},
    {MODKEY, XK_Left, focusstack, {.i = -1} },
    {MODKEY, XK_Right, focusstack, {.i = +1} },
    {MODKEY, XK_i, incnmaster, {.i = +1}},
    {MODKEY | Mod1Mask, XK_Left, viewtoleft, {0} },
    {MODKEY | Mod1Mask, XK_Right, viewtoright, {0} },
    {MODKEY | ShiftMask, XK_a, spawn, SHCMD("$HOME/.config/dwmbar/scripts/dmenu-script1") },
    //{MODKEY | ShiftMask, XK_t, schemeToggle, {0}},
    {MODKEY | ShiftMask, XK_z, schemeCycle, {0}},
    {MODKEY, XK_p, incnmaster, {.i = -1}},
    {MODKEY, XK_Up, setmfact, {.f = -0.05}},
    {MODKEY, XK_Down, setmfact, {.f = +0.05}},
    {MODKEY | ShiftMask, XK_Return, zoom, {0}},
    {MODKEY, XK_Tab, view, {0}},
    {MODKEY, XK_c, killclient, {0}},
    {MODKEY | ShiftMask, XK_t, setlayout, {.v = &layouts[0]}},
    {MODKEY | ShiftMask, XK_f, setlayout, {.v = &layouts[1]}},
    {MODKEY | ShiftMask, XK_m, setlayout, {.v = &layouts[2]}},
    {MODKEY, XK_s, togglesticky, {0}},
    {MODKEY, XK_space, setlayout, {0}},
    {MODKEY | ShiftMask, XK_space, togglefloating, {0}},
    {MODKEY, XK_0, view, {.ui = ~0}},
    {MODKEY | ShiftMask, XK_0, tag, {.ui = ~0}},
    {MODKEY, XK_comma, focusmon, {.i = -1}},
    {MODKEY, XK_period, focusmon, {.i = +1}},
    {MODKEY | ShiftMask, XK_comma, tagmon, {.i = -1}},
    {MODKEY | ShiftMask, XK_period, tagmon, {.i = +1}},
    {MODKEY, XK_minus, setgaps, {.i = -1}},
    {MODKEY, XK_plus, setgaps, {.i = +1}},
    {MODKEY | ShiftMask, XK_equal, setgaps, {.i = 0}},
    TAGKEYS(XK_1, 0) TAGKEYS(XK_2, 1) TAGKEYS(XK_3, 2) TAGKEYS(XK_4, 3)
        TAGKEYS(XK_5, 4) TAGKEYS(XK_6, 5) TAGKEYS(XK_7, 6) TAGKEYS(XK_8, 7)
            TAGKEYS(XK_9, 8){MODKEY | ShiftMask, XK_s, exitdwm, {0}},
};

#endif /* KEYS_H */
