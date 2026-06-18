# Wofi – Lanzador temático para Hyprland

Configuración de **Wofi** sincronizada con el sistema de temas de `hyperland/themes/palettes.json`.

## Estructura

```
wofi/
├── config          # Opciones de Wofi (drun, imágenes, color/style)
├── style.base.css  # Plantilla CSS (placeholders {{WOFI_BG}}, etc.)
├── style.css       # Generado por apply-theme.sh — no editar a mano
└── colors          # Paleta hex por línea (opcional, referencia)
```

## Instalación

Se despliega automáticamente con:

```bash
~/configurations/hyperland/scripts/deploy-configs.sh
```

O manualmente:

```bash
cp -r wofi ~/.config/wofi
~/configurations/hyperland/scripts/apply-theme.sh blue
```

## Uso

| Acción | Comando / atajo |
|--------|-----------------|
| Lanzador drun | `Super+D` o clic en icono de distro en Waybar |
| Script dedicado | `~/.config/hypr/scripts/wofi-launch.sh` |

`wofi-launch.sh` fuerza `--conf` y `--style` para cargar siempre el tema activo.

## Temas

Los colores se derivan del bloque `waybar` del tema en `palettes.json`. Al cambiar tema (botón Tema en Ignis o `apply-theme.sh`), se regeneran:

- `~/.config/wofi/style.css`
- `~/.config/wofi/colors`
- Copias en este repo (`wofi/style.css`, `wofi/colors`)

Wofi lee el CSS al abrir; no hace falta reiniciar el proceso.

## Personalización

1. Edita `style.base.css` (estructura y selectores GTK).
2. Ejecuta `apply-theme.sh` para regenerar `style.css` con colores del tema activo.
3. Vuelve a abrir Wofi para ver cambios.

## Nota sobre transparencia

En Hyprland + Wofi el fondo opaco puede verse semitransparente por limitaciones del compositor con capas Wayland. El texto y el campo de búsqueda siguen siendo legibles sobre el wallpaper.
