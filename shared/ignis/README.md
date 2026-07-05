# Ignis – Shell GTK para Hyprland

Barra de estado, centro de control, OSD, launcher y selector de fondos basados en [Ignis](https://github.com/ignis-sh/ignis).

## Estructura en el repo

```
ignis/
├── config.py              # Punto de entrada
├── user_options.py        # Plantilla de opciones (se copia a ~/.config/ignis/)
├── modules/               # Ventanas y widgets
│   ├── control_center/    # Centro de control
│   ├── bar_position.py    # Sync posición Waybar
│   └── osd/               # OSD de volumen
├── scss/                  # Estilos
└── configs/               # JSON auxiliares (p. ej. wallpapers)
```

Los temas viven en `hyperland/themes/palettes.json` y se copian a `~/.config/ignis/themes/` en el deploy.

## Instalación

Desde la raíz del clone:

```bash
./hyperland/scripts/deploy-configs.sh
```

Arranque manual: `ignis init` (también en `hyperland/conf.d/exec.conf`).

Dependencia: paquete `ignis` (Python/GTK4) de tu distro o AUR.

## Componentes principales

### Centro de control

- Clic en hostname en Waybar (o bind en `hyperland/conf.d/keybinds.conf`).
- Botón **Tema**: cicla temas vía `apply-theme.sh`.
- **Hyprsunset**: temperatura de color.

### Sync con Waybar

Estado compartido:

- `~/.cache/hypr/waybar-position.json`
- `~/.config/ignis/user_options.json` → `bar.position`

Cuando Waybar está abajo, el centro de control y el OSD se alinean al borde inferior.

### Temas

`apply-theme.sh` (desde el clone):

```bash
./hyperland/scripts/apply-theme.sh tokyo_night
```

Actualiza en `~/.config/`:

- `hypr/conf.d/theme.conf`
- `waybar/waybar-colors.css`
- `wofi/colors` y `wofi/style.css`
- `cava/config` (Wayland)

## Opciones de usuario

Archivo en el sistema (no en el repo): `~/.config/ignis/user_options.json`

| Campo | Valores |
|-------|---------|
| `theme.active` | `blue`, `green`, `tokyo_night`, `catppuccin_mocha`, … |
| `bar.position` | `top` / `bottom` |
| `bar.height` | Altura Waybar (default 26) |
| `wallpaperpicker.image_base_path` | `~/.config/fondos` |
| `wallpaperpicker.other_image_base_path` | `~/.config/fondos/other` |

Rutas en `configs/wallpapers.json` y `other-wallpapers.json` (relativas a `$HOME`).

## Personalización

- SCSS: `ignis/scss/`
- Nuevos temas: edita `hyperland/themes/palettes.json`, regenera Wofi/Cava si hace falta, ejecuta `apply-theme.sh`.
