# Componentes compartidos (`shared/`)

Configuración y scripts usados por **i3** y **Hyprland** (y parcialmente por DWM). Se despliegan a `~/.config/` con los instaladores de cada stack.

## Instalación

```bash
# Solo cnf-bin (config + binarios)
./shared/install.sh

# Compilar Rust + instalar
./shared/cnf-bin/build-install.sh

# Como parte de un stack completo
./hyprland/scripts/install-hypr.sh --binaries
./I3/scripts/install-i3.sh --binaries
```

El script maestro de dotfiles es `./deploy-configs.sh` (raíz del repo).

---

## Contenido

| Carpeta | Descripción | README |
|---------|-------------|--------|
| **cnf-bin/** | Scripts, `cnf-info`, `cnf-media`, `config.toml`, managers | [cnf-bin/README.md](cnf-bin/README.md) |
| **bash/** | Fragmentos bashrc (X11 / Hypr) | [bash/README.md](bash/README.md) |
| **tmux/** | Config tmux + temas por palette | [tmux/README.md](tmux/README.md) |
| **nvim/** | Neovim (LazyVim) | [nvim/README.md](nvim/README.md) |
| **polybar/** | Barra alternativa (i3) | [polybar/README.md](polybar/README.md) |
| **wofi/** | Lanzador Wayland | [wofi/README.md](wofi/README.md) |
| **cava/** | Visualizador de audio | [cava/README.md](cava/README.md) |
| **copyq/** | Portapapeles + temas | [copyq/README.md](copyq/README.md) |
| **eww/** | Widgets (legacy / opcional) | [eww/README.md](eww/README.md) |
| **ignis/** | Shell GTK (Hyprland) | [ignis/README.md](ignis/README.md) |
| **session/** | dunst, sdm, binscripts | [session/README.md](session/README.md) |
| **utilidades/** | monitor, cpu-mode, etc. | [utilidades/README.md](utilidades/README.md) |
| **fondos/** | Wallpapers (i3 / Hypr) | — |

---

## cnf-bin (resumen)

- **Config:** `~/.config/cnf-bin/config.toml` (override local: `config.local.toml`)
- **Binarios:** `/usr/local/bin` — no van a `~/.config/`
- **Principales:** `cnf-info`, `cnf-media`, `sdm`, `thinkfan`, `docker-manager`, `web-manager`, `print-manager`

Ver documentación completa en [cnf-bin/README.md](cnf-bin/README.md).

---

## PATH

Tras instalar binarios y cargar bashrc:

```text
/usr/local/bin
~/Games/configurations/shared/utilidades   # vía bashrc si existe el clone
```

---

## Notas

- Los README **no** se copian a `~/.config/` (solo configs y scripts de runtime).
- **powerline** vive en `hyprland/powerline/` (solo Hyprland).
