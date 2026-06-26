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
| `bash/` | `~/.config/bash/` + `~/.bashrc` | Shell Hyprland (powerline) o X11 (legacy) |
| `powerline/` | `~/.config/powerline/` | Prompt bash |
| `nvim/` | `~/.config/nvim/` | LazyVim + tema Hyprland |
| `tmux/` | `~/.config/tmux/` | Multiplexor + colores por tema |
| `cnf-bin/` | `~/.config/cnf-bin/` (solo config) + `/usr/local/bin` (binarios, manual) | `cnf-info`, scripts, config maestra |
| `utilidades/` | *(solo repo)* | Monitor, cpu-mode, etc. (PATH al clone) |

> **Nota:** la carpeta se llama `hyperland/` (convención histórica del repo); el destino real es `~/.config/hypr/`.

## Probar la configuración (desde cero)

```bash
# 1. Clona donde quieras (ejemplo)
git clone https://github.com/TU_USUARIO/TU_REPO.git dotfiles
cd dotfiles

# 2. Despliega todo el stack Hyprland
./hyperland/scripts/deploy-configs.sh

# 3. Inicia sesión con Hyprland (SDM en consola, greetd, startx manual, etc.)
```

El script detecta la estructura **split** del repo (`hyperland/` + carpetas hermanas). No hace falta editar rutas absolutas.

### Qué hace `deploy-configs.sh`

1. Copia el stack Hyprland → `~/.config/` (**sin** `README.md`, `docs/` ni otros `.md`)
2. Por defecto, copia el mismo contenido → `$HOME/Games/configurations` (mirror local; no hace `git push`)
3. Copia `hyperland/themes/palettes.json` → `~/.config/ignis/themes/`
4. Aplica el tema activo con `apply-theme.sh` (reinicia waybar, `hyprctl reload`, ignis)
5. Con `--all`, además reinicia **swaync** al final

```bash
./hyperland/scripts/deploy-configs.sh              # ~/.config + mirror + apply-theme
./hyperland/scripts/deploy-configs.sh --config       # solo ~/.config (sin mirror)
./hyperland/scripts/deploy-configs.sh --all          # completo + reinicio de swaync
```

> **Documentación:** los `README.md` y carpetas `docs/` **solo** viven en el repo (`~/hyprland` o `~/Games/configurations`). Nunca se copian a `~/.config/`.

## Temas unificados

Definidos en `hyperland/themes/palettes.json`. Un comando aplica colores a Hypr, Waybar, Wofi, Cava, Tmux, Nvim y Powerline:

```bash
# Desde la raíz del clone
./hyperland/scripts/apply-theme.sh [theme_id]

# Ejemplos
./hyperland/scripts/apply-theme.sh blue
./hyperland/scripts/apply-theme.sh catppuccin_mocha
```

Sin argumento usa el tema guardado en `~/.config/ignis/user_options.json`.

`apply-theme.sh` escribe **solo** en `~/.config/` (no modifica el clone).

## Regenerar perfiles (mantenedores)

Tras editar `palettes.json` o plantillas base:

```bash
./hyperland/scripts/generate-wofi-wayland.sh
./hyperland/scripts/generate-cava-wayland.sh
./hyperland/scripts/generate-tmux-colors.sh
```

Luego vuelve a desplegar o ejecuta `apply-theme.sh`.

## Entornos Hyprland vs X11/i3

| Script | Uso |
|--------|-----|
| `hyperland/scripts/x11-environment.sh` | Perfil **i3/X11**: bash legacy, env X11, cava X11 |
| `hyperland/scripts/hypr-environment.sh` | Vuelta a **Hyprland/Wayland** |

```bash
./hyperland/scripts/x11-environment.sh && source ~/.bashrc
./hyperland/scripts/hypr-environment.sh && source ~/.bashrc
```

Estado: `~/.cache/hypr/session-mode`.

## Tmux

Arranque manual en terminal; alias `tm` en bashrc.

```bash
./hyperland/scripts/tmux-atajos.sh all
```

- Prefijo **Alt+a** (sin Ctrl); **Alt+Space** / **Alt+Shift+Space** + flechas
- **Alt+\\** / **Alt+-** splits; barra pac/AUR/flat (cache 1 h). Sin TPM

## Waybar – módulos destacados

| Módulo | Función |
|--------|---------|
| `custom/launcher` | Icono de distro; clic → Wofi drun |
| `custom/bar-position` | Flecha ↑/↓; alterna barra top/bottom |
| `custom/bar-autohide` | `-` / `^` / `v`; autohide vía binario `wb_autohide` |
| `custom/kblight` | Luz teclado (`cnf-info --kbdlight`, solo lectura) |
| `custom/media-*` | Control multimedia vía `playerctl` |

Brillo de pantalla: atajos Hypr → `cnf-info --brillo +/-`. Ver [`cnf-bin/README.md`](cnf-bin/README.md).

## cnf-bin y utilidades

- [`cnf-bin/README.md`](cnf-bin/README.md) — `cnf-info`, managers, deploy, secretos
- [`utilidades/README.md`](utilidades/README.md) — scripts opcionales (monitor, emuladores); carpeta borrable

## Documentación por componente

- [`cnf-bin/README.md`](cnf-bin/README.md) — cnf-info y scripts
- [`hyperland/README.md`](hyperland/README.md) — Hyprland, keybinds, scripts
- [`i3-wm/README.md`](i3-wm/README.md) — i3/X11, bandeja i3bar, bumblebee-status
- [`waybar/README.md`](waybar/README.md) — Barra y módulos
- [`wofi/README.md`](wofi/README.md) — Lanzador y perfiles por tema
- [`ignis/README.md`](ignis/README.md) — Shell GTK
- `tmux/docs/atajos.md` — Tmux (atajos; script: `hyperland/scripts/tmux-atajos.sh`)

## Otras configuraciones

- `session/` — selector de sesión en consola (`sdm`; no es un display manager)
- `copyq/` — portapapeles
- `i3-wm/`, `dwm-full/`, `polybar/` — entornos alternativos

## Descargar solo una carpeta

Si no quieres clonar todo el repositorio, navega a la carpeta que te interese en GitHub, copia su URL y descárgala con [DownGit](https://downgit.github.io/#/home).
