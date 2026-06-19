# Configuraciones de escritorio

Repositorio de dotfiles para entornos Linux (Hyprland, Waybar, Ignis, Wofi, Cava, i3, DWM, etc.).

## Stack Hyprland

| Carpeta en el repo | Destino al desplegar | Descripción |
|-------------------|----------------------|-------------|
| `hyperland/` | `~/.config/hypr/` | Compositor, keybinds, scripts, temas |
| `waybar/` | `~/.config/waybar/` | Barra de estado |
| `ignis/` | `~/.config/ignis/` | Shell GTK (centro de control, OSD) |
| `wofi/` | `~/.config/wofi/` | Lanzador temático |
| `cava/` | `~/.config/cava/` | Visualizador de audio (perfiles por tema) |

> **Nota:** la carpeta se llama `hyperland/` (convención histórica del repo); el destino real es `~/.config/hypr/`.

## Probar la configuración (desde cero)

```bash
# 1. Clona donde quieras (ejemplo)
git clone https://github.com/TU_USUARIO/TU_REPO.git dotfiles
cd dotfiles

# 2. Despliega todo el stack Hyprland
./hyperland/scripts/deploy-configs.sh

# 3. Inicia sesión con Hyprland (según tu gestor de display / SDM)
```

El script detecta solo la estructura del repo (layout **split**: `hyperland/` + carpetas hermanas, o layout **monolítico** con todo en la raíz). No hace falta editar rutas absolutas en los scripts.

### Qué hace `deploy-configs.sh`

1. Copia `waybar/`, `wofi/`, `ignis/`, `cava/` y `hyperland/` → `~/.config/`
2. Copia `hyperland/themes/palettes.json` → `~/.config/ignis/themes/`
3. Aplica el primer tema de `palettes.json` (`order[0]`) con `apply-theme.sh`
4. Recarga Hyprland e inicia servicios (Ignis, Waybar, swaync, hypridle)

Opcional para quien mantenga un mirror en GitHub:

```bash
./hyperland/scripts/deploy-configs.sh --github
```

Solo sincroniza **desde este clone hacia otro repo local** cuyo `origin` apunte a GitHub; no es necesario para probar la config.

## Temas unificados

Definidos en `hyperland/themes/palettes.json`. Un comando aplica colores a Hypr, Waybar, Wofi y Cava (Wayland):

```bash
# Desde la raíz del clone
./hyperland/scripts/apply-theme.sh [theme_id]

# Ejemplos
./hyperland/scripts/apply-theme.sh blue
./hyperland/scripts/apply-theme.sh catppuccin_mocha
```

Sin argumento usa el tema guardado en `~/.config/ignis/user_options.json`.

`apply-theme.sh` escribe **solo** en `~/.config/` (no modifica el clone).

## Regenerar perfiles Wofi / Cava (mantenedores)

Tras editar `palettes.json` o plantillas base:

```bash
./hyperland/scripts/generate-wofi-wayland.sh   # → wofi/wayland/colors.{slug}, style.{slug}.css
./hyperland/scripts/generate-cava-wayland.sh   # → cava/wayland/config.{slug}
```

Luego vuelve a desplegar o ejecuta `apply-theme.sh`.

## Waybar – módulos destacados

| Módulo | Función |
|--------|---------|
| `custom/launcher` | Icono de distro; clic → Wofi drun |
| `custom/bar-position` | Flecha ↑/↓; alterna barra top/bottom |
| `custom/media-*` | Control multimedia vía `playerctl` |

## Documentación por componente

- [`hyperland/README.md`](hyperland/README.md) — Hyprland, keybinds, scripts
- [`waybar/README.md`](waybar/README.md) — Barra y módulos
- [`wofi/README.md`](wofi/README.md) — Lanzador y perfiles por tema
- [`ignis/README.md`](ignis/README.md) — Shell GTK

## Otras configuraciones

- `session/` — selector de sesión (SDM)
- `copyq/` — portapapeles
- `i3-wm/`, `dwm-full/`, `polybar/` — entornos alternativos

## Descargar solo una carpeta

Si no quieres clonar todo el repositorio, navega a la carpeta que te interese en GitHub, copia su URL y descárgala con [DownGit](https://downgit.github.io/#/home).
