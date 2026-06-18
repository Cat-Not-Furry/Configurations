# Ignis – Shell GTK para Hyprland

Barra de estado, centro de control, OSD, launcher y selector de fondos basados en [Ignis](https://github.com/ignis-sh/ignis).

## Estructura

```
ignis/
├── config.py              # Punto de entrada
├── user_options.py        # Opciones persistentes (tema, barra, fondos)
├── modules/               # Ventanas y widgets
│   ├── control_center/    # Centro de control (Quick Settings, media, usuario)
│   ├── bar_position.py    # Sync posición Waybar top/bottom
│   ├── osd/               # OSD de volumen
│   └── ...
├── scss/                  # Estilos compilados al iniciar
└── themes/                # Copiado desde hyperland/themes/ en deploy
```

## Instalación

```bash
~/configurations/hyperland/scripts/deploy-configs.sh
```

Ignis se reinicia al final del deploy. Arranque manual: `ignis init`.

## Componentes principales

### Centro de control

- Atajo: clic en hostname en Waybar o bind configurado en Hyprland.
- Botón **Tema**: cicla temas de `palettes.json` vía `apply-theme.sh`.
- **Hyprsunset**: control de temperatura de color (1000–20000 K).

### Sync con posición de Waybar

Cuando Waybar está abajo (`custom/bar-position` en Waybar):

- El panel del centro de control se alinea al borde inferior.
- El OSD de volumen sube con margen para no solaparse con la barra.

Estado compartido: `~/.cache/hypr/waybar-position.json` y `user_options.json` → `bar.position`.

### Temas

Paleta en `hyperland/themes/palettes.json`. `apply-theme.sh` actualiza:

- Bordes Hypr (`conf.d/theme.conf`)
- Colores Waybar (`waybar-colors.css`)
- Estilos Wofi (`wofi/style.css`)

Ignis recarga CSS desde el botón Tema sin reiniciar el proceso.

## Opciones de usuario

Archivo: `~/.config/ignis/user_options.json`

| Grupo | Campos relevantes |
|-------|-------------------|
| `theme.active` | ID del tema activo (`blue`, `green`, `tokyo_night`, …) |
| `bar.position` | `top` o `bottom` (sync con Waybar) |
| `bar.height` | Altura Waybar para márgenes (default 26) |

## Personalización

- SCSS: `ignis/scss/`
- Nuevos temas: edita `hyperland/themes/palettes.json` y ejecuta `apply-theme.sh`.
