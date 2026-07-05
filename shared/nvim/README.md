# Neovim (LazyVim)

Config compartida i3 / Hyprland. Tema visual: **Tokyo Night** sincronizado con `palettes.json`.

## Tema

| Entorno | Cómo se aplica |
|---------|----------------|
| **Hyprland** | `apply-theme.sh [theme_id]` → `~/.config/nvim/lua/config/theme.generated.lua` |
| **i3 / X11** | `apply-i3-theme.sh [classic\|iceberg]` → mismo archivo (mapeo: `classic`→`classic`, `iceberg`→`blue`) |

También se actualiza al cambiar tema i3 vía `activate_x11_shared_themes` (tmux, cava, copyq).

El plugin `config/hypr-theme.lua` lee `theme.generated.lua` y configura `tokyonight.nvim`. En nvim: `:HyprThemeReload` tras cambiar tema.

Deploy: `shared/nvim/` → `~/.config/nvim/` (merge). `theme.generated.lua` **no** va en el repo; se genera en runtime.

Base: [LazyVim](https://github.com/LazyVim/LazyVim) — ver [documentación upstream](https://lazyvim.github.io/installation).
