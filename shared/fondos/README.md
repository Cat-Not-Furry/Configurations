# fondos — wallpapers compartidos (i3 / Hyprland)

Fuente en el repo: `shared/fondos/`. En el sistema viven en **`~/.config/fondos/`** (no bajo `~/.config/i3/`).

```
shared/fondos/
├── *.jpg, *.png, …          # wallpapers raíz
└── other/                   # paquetes .7z opcionales (ver other/README.md)
```

## Deploy e instalación

Por defecto **`deploy-configs.sh` no copia fondos**. Solo se instalan con flags explícitas:

| Flag | Qué copia a `~/.config/fondos/` |
|------|----------------------------------|
| `--fondos` | Wallpapers de la raíz (`shared/fondos/*.{jpg,png,…}`) — merge |
| `--fondos-all` | Lo anterior + contenido de `other/` (`.7z` y archivos; **sin** `*.md`) |

```bash
./deploy-configs.sh --config-i3 --fondos
./I3/scripts/install-i3.sh --fondos-all
./hyprland/scripts/install-hypr.sh --fondos
```

Sin flags: configs y scripts se despliegan; tus fondos locales en `~/.config/fondos/` no se tocan.

## Uso en sesión

| Herramienta | Ruta |
|-------------|------|
| `fondo` (X11 / i3) | `~/.config/fondos/`, `~/.config/fondos/other/` |
| Ignis picker (Hyprland) | `user_options.wallpaperpicker.image_base_path` → `~/.config/fondos` |
| `wofi_wallpaper.sh` | `STATIC_WALL_DIR=$HOME/.config/fondos/` |
| `hyprlock.conf` | `~/.config/fondos/…` |

Comandos habituales (i3):

```bash
fondo f    # aleatorio (excluye other/)
fondo p    # aleatorio solo other/
fondo s    # elegir por número
```

Migrar desde la ruta antigua:

```bash
mkdir -p ~/.config/fondos
mv ~/.config/i3/fondos/* ~/.config/fondos/ 2>/dev/null || true
```

Config maestra: `[paths] fondos` en `shared/cnf-bin/config.toml`.
