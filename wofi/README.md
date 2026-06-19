# Wofi – Lanzador temático para Hyprland

Configuración de **Wofi** sincronizada con `hyperland/themes/palettes.json`.

## Estructura en el repo

```
wofi/
├── config              # Opciones globales (drun, imágenes, tamaño)
├── style.base.css      # Plantilla CSS (placeholders {{WOFI_BG}}, etc.)
└── wayland/            # Perfiles pregenerados por tema
    ├── colors.{slug}
    └── style.{slug}.css
```

En `~/.config/wofi/` tras aplicar un tema:

```
~/.config/wofi/
├── config
├── style.base.css
├── wayland/            # Perfiles (copiados en deploy)
├── colors              # Activo — copia de wayland/colors.{slug}
└── style.css           # Activo — copia de wayland/style.{slug}.css
```

## Instalación

Desde la **raíz del clone**:

```bash
./hyperland/scripts/deploy-configs.sh
```

Manual (solo Wofi + tema):

```bash
cp wofi/config wofi/style.base.css ~/.config/wofi/
cp -r wofi/wayland ~/.config/wofi/
./hyperland/scripts/apply-theme.sh blue
```

## Uso

| Acción | Atajo / comando |
|--------|-----------------|
| Lanzador drun | `Super+D` |
| Script dedicado | `~/.config/hypr/scripts/wofi-launch.sh` |
| Menús personalizados | `Super+Shift+S`, `Super+Shift+A` (misma estética vía `lib/wofi-common.sh`) |

`wofi-launch.sh` usa `--conf` y `--style` del tema activo.

## Temas

Cada tema en `palettes.json` tiene campos `wofi` y `cava` (slug, p. ej. `catppuccin-mocha`). `apply-theme.sh` copia el perfil correspondiente a `colors` y `style.css` activos.

Para regenerar perfiles tras cambiar colores:

```bash
./hyperland/scripts/generate-wofi-wayland.sh
```

Wofi lee el CSS al abrir; no hace falta reiniciar un daemon.

## Personalización

1. Edita `style.base.css` (selectores GTK).
2. Ejecuta `generate-wofi-wayland.sh`.
3. `apply-theme.sh [theme_id]` o vuelve a abrir Wofi.

Copia de plantilla de temas: `hyperland/themes/palettes.example.json` → `palettes.json`.

## Nota sobre transparencia

En Hyprland el fondo de Wofi puede verse semitransparente por limitaciones del compositor con capas Wayland. El texto y el campo de búsqueda siguen siendo legibles.
