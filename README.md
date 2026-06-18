# Configuraciones de escritorio

Repositorio central de dotfiles para entornos Linux (Hyprland, Waybar, Ignis, Wofi, i3, DWM, etc.).

## Stack Hyprland 

| Carpeta | Destino en `~/.config/` | Descripción |
|---------|-------------------------|-------------|
| `hyperland/` | `hypr/` | Compositor, keybinds, scripts, temas |
| `waybar/` | `waybar/` | Barra de estado |
| `ignis/` | `ignis/` | Shell GTK (centro de control, OSD) |
| `wofi/` | `wofi/` | Lanzador de aplicaciones temático |

## Despliegue rápido (Hyprland)

Desde este repositorio (ruta relativa al clone):

```bash
/path/al/repo/hyperland/scripts/deploy-configs.sh
```

El script auto-detecta si `waybar/`, `wofi/` e `ignis/` están junto a Hypr (monolítico) o en la carpeta padre (split).

Si trabajas en un clone local distinto (p. ej. `~/hyprland`), al final sincroniza automáticamente con el repo GitHub en `~/Games/configurations` (detectado por remote `github` en origin).

El script:

1. Copia `waybar/`, `wofi/`, `hyperland/`, `ignis/` a `~/.config/`
2. Copia `themes/palettes.json` → `~/.config/ignis/themes/`
3. Ejecuta `apply-theme.sh` con el tema activo
4. Recarga Hyprland y reinicia Ignis

## Temas unificados

Definidos en `hyperland/themes/palettes.json`. Un solo comando aplica colores a Hypr, Waybar y Wofi:

```bash
~/configurations/hyperland/scripts/apply-theme.sh [theme_id]
```

Sin argumento usa el tema guardado en `~/.config/ignis/user_options.json`.

## Waybar – módulos nuevos

| Módulo | Función |
|--------|---------|
| `custom/launcher` | Icono de distro; clic → Wofi drun |
| `custom/bar-position` | Flecha ↑/↓; alterna barra top/bottom |

Ver `waybar/README.md`, `wofi/README.md`, `ignis/README.md` y `hyperland/README.md` para detalle por componente.

## Otras configuraciones

- `session/` – scripts de sesión y utilidades
- `copyq/` – portapapeles
- `i3-wm/`, `dwm-full/`, `polybar/` – entornos alternativos

# Si neceitas un componente en especifico navega a el y luego pega la ruta en [DownGit](https://downgit.github.io/#/home)
