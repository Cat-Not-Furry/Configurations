# Configuraciones de escritorio

Dotfiles para entornos Linux: **Hyprland** (Wayland), **i3** (X11), **DWM**, que utilizan temas personalizados para algunas herramientas (`cnf-bin`, tmux, nvim, etc.).

Pensado para clonar  y desplegar con scripts incluidos. Los README y scripts **no se copian** a `~/.config/`

---

## Inicio rápido

| Objetivo | Comando |
|----------|---------|
| **Hyprland** (config + recarga) | `./hyprland/scripts/install-hypr.sh` |
| **i3** (config + recarga) | `./I3/scripts/install-i3.sh` |
| **Deploy maestro** | `./deploy-configs.sh [--config-hypr \| --config-i3] [--fondos \| --fondos-all]` |
| **Binarios** (`cnf-info`, `thinkfan`, …) | `./shared/install.sh --binaries` |
| **Compilar Rust + instalar** | `./shared/cnf-bin/build-install.sh` |
| **Solo cnf-bin config** | `./shared/install.sh --config-only` |

Añade `--binaries` a `install-hypr.sh` / `install-i3.sh` para copiar también a `/usr/local/bin` (donde yo los instalo).

---

## Estructura del repositorio

```
configurations/
├── README.md
├── deploy-configs.sh         ← despliegue maestro → ~/.config/
├── I3/                       ← stack i3 (X11)
│   ├── i3-wm/
│   ├── bumblebee-status/
│   └── scripts/
│       ├── install-i3.sh     ← despliegue i3
│       └── deploy-i3.sh
├── hyprland/                 ← stack Hyprland (Wayland)
│   ├── hyperland/            → ~/.config/hypr/
│   ├── waybar/
│   ├── powerline/
│   └── scripts/
│       └── install-hypr.sh   ← despliegue Hyprland
├── shared/                   ← componentes compartidos entre stacks
│   ├── cnf-bin/              ← scripts, cnf-info, cnf-media, config.toml
│   ├── bash/, tmux/, nvim/, polybar/, wofi/, cava/, fondos/, …
│   └── install.sh
├── dwm-full/                 ← fork DWM + st (compilación manual)
└── btop/                     ← tema btop
```

---

## Requisitos generales

- **Arch Linux** (o derivado) — ya que los ejemplos usan `pacman`
- **Rust + cargo** — solo si compilas `cnf-info` / `cnf-media` 
- **sudo** — para instalar en `/usr/local/bin` y escribir en `/proc/acpi/ibm/fan` (`thinkfan`), (si se prefiere instalar en `~/.local/bin`, sudo no es necesario).
- Clone del repo en una ruta fija; los scripts resuelven rutas relativas a este repo.

### Paquetes habituales (Hyprland)

```bash
sudo pacman -S hyprland waybar wofi playerctl brightnessctl wireplumber \
  lm_sensors polkit-kde-agent xdg-desktop-portal-hyprland hypridle hyprlock
```

### Paquetes habituales (i3)

```bash
sudo pacman -S i3 i3status i3lock xorg-xinit picom playerctl brightnessctl \
  blueman network-manager-applet copyq
```

Detalle por componente en los README de cada carpeta.

---

## Descargar solo un stack (DownGit)

Si no quieres clonar todo el repo, puedes bajar carpetas concretas con [DownGit](https://downgit.github.io/): pega la URL de la carpeta en GitHub y descarga el ZIP.

Repositorio: `https://github.com/Cat-Not-Furry/Configurations`

| Quieres | Descarga estas carpetas | Notas |
|---------|-------------------------|-------|
| **Hyprland** | `hyprland/` + `shared/` | Obligatorio `shared/` (ignis, wofi, cnf-bin, tmux, …) |
| **i3** | `I3/` + `shared/` + `hyprland/hyperland/scripts/` | Los instaladores usan `deploy-configs.sh` dentro de `hyprland/hyperland/scripts/` |
| **Solo cnf-bin** | `shared/cnf-bin/` (+ `shared/install.sh` si quieres el script) | O baja `shared/` entero |
| **DWM** | `dwm-full/` + `shared/cnf-bin/` | Para la barra con `cnf-info` / `cnf-media` |
| **btop** | `btop` | Opcional; no dependen del resto |

Enlaces directos (rama `main`):

- [Hyprland](https://downgit.github.io/#/home?url=https://github.com/Cat-Not-Furry/Configurations/tree/main/hyprland)
- [i3](https://downgit.github.io/#/home?url=https://github.com/Cat-Not-Furry/Configurations/tree/main/I3)
- [shared](https://downgit.github.io/#/home?url=https://github.com/Cat-Not-Furry/Configurations/tree/main/shared)
- [Scripts de deploy](https://downgit.github.io/#/home?url=https://github.com/Cat-Not-Furry/Configurations/tree/main/hyprland/hyperland/scripts) (necesario para i3)
- [dwm-full](https://downgit.github.io/#/home?url=https://github.com/Cat-Not-Furry/Configurations/tree/main/dwm-full)

Tras descomprimir, **mantén la estructura de carpetas** y coloca todo bajo la misma raíz (p. ej. `~/Configurations/`):

```
~/Configurations/
├── I3/              # si usas i3
├── hyprland/        # si usas Hyprland (incluye hyperland/scripts/)
└── shared/          # casi siempre necesario
```

Luego ejecuta el instalador correspondiente desde esa raíz (ver sección siguiente).

---

## Flujos de instalación (VM)

### 1. Hyprland completo

```bash
git clone https://github.com/Cat-Not-Furry/Configurations.git ~/.cache/Configurations
cd ~/.cache/Configurations

# Config → ~/.config/ (hypr, waybar, ignis, wofi, cnf-bin, tmux, …)
./hyprland/scripts/install-hypr.sh

# Opcional: binarios en /usr/local/bin
./hyprland/scripts/install-hypr.sh --binaries

# Opcional: fondos → ~/.config/fondos/
./hyprland/scripts/install-hypr.sh --fondos-all

# Tema
./hyprland/hyperland/scripts/apply-theme.sh blue

# Cerrar sesión e iniciar Hyprland (p. ej. con sdm)
```

### 2. i3 completo

```bash
git clone https://github.com/Cat-Not-Furry/Configurations.git ~/.cahe/Configurations
cd ~/.cahe/Configurations

./I3/scripts/install-i3.sh
./I3/scripts/install-i3.sh --binaries   # opcional
./I3/scripts/install-i3.sh --fondos-all # opcional: wallpapers → ~/.config/fondos/

# Tema i3 (ventanas, barra, nvim vía palettes.json)
~/.config/i3/scripts/apply-i3-theme.sh classic

# Iniciar i3 (p. ej. startx / sdm)
```

### 3. Solo binarios y config cnf-bin

```bash
./shared/install.sh              # config.toml → ~/.config/cnf-bin/
./shared/install.sh --binaries   # + /usr/local/bin
./shared/cnf-bin/build-install.sh  # compila Rust + instala
```

### 4. DWM (fork propio)

Ver [`dwm-full/README.md`](dwm-full/README.md) y [`dwm-full/install.sh`](dwm-full/install.sh).

---

## Scripts centrales

| Script | Qué hace |
|--------|----------|
| [`deploy-configs.sh`](deploy-configs.sh) | Despliegue maestro → `~/.config/` (raíz del repo) |
| [`hyprland/hyperland/scripts/deploy-configs.sh`](hyprland/hyperland/scripts/deploy-configs.sh) | Implementación (también invocable directamente) |
| [`hyprland/hyperland/scripts/install-local-binaries.sh`](hyprland/hyperland/scripts/install-local-binaries.sh) | `cnf-bin/bin/*`, utilidades, `wb_autohide` → `/usr/local/bin` |
| [`shared/cnf-bin/build-install.sh`](shared/cnf-bin/build-install.sh) | Compila `cnf-info` + `cnf-media` e instala |
| [`I3/scripts/deploy-i3.sh`](I3/scripts/deploy-i3.sh) | Wrapper: `deploy-configs.sh --config-i3` |

Opciones de `deploy-configs.sh`:

```text
(sin flags)       Hyprland + i3 + compartidos
--config-hypr     Solo stack Hyprland
--config-i3       Solo stack i3
--config          Sin mirror al repo local
--all             Reinicia swaync (Hyprland)
--fondos          Copia wallpapers del repo → ~/.config/fondos/ (merge; sin other/)
--fondos-all      Igual que --fondos e incluye shared/fondos/other/ (sin README)
```

Por defecto el deploy **no** copia fondos. Ver [`shared/fondos/README.md`](shared/fondos/README.md).

---

## Documentación por carpeta

| Carpeta | README | Instalación |
|---------|--------|-------------|
| [I3/](I3/README.md) | Stack i3 | `I3/scripts/install-i3.sh` |
| [hyprland/](hyprland/README.md) | Stack Hyprland | `hyprland/scripts/install-hypr.sh` |
| [shared/](shared/README.md) | Componentes compartidos | `shared/install.sh` |
| [shared/fondos/](shared/fondos/README.md) | Wallpapers (`~/.config/fondos/`) | `--fondos` en deploy/install |
| [shared/cnf-bin/](shared/cnf-bin/README.md) | cnf-info, cnf-media, thinkfan, managers | `shared/cnf-bin/build-install.sh` |
| [dwm-full/](dwm-full/README.md) | DWM + st | `dwm-full/install.sh` |
| [btop/](btop/README.md) | Monitor de recursos | `btop/install.sh` |
| [waybar-auto-hide-cnf/](waybar-auto-hide-cnf/README.md) | Autohide Waybar | `waybar-auto-hide-cnf/build-and-install.sh` |
| [i3space/](i3space/README.md) | Overview workspaces i3 | `i3space/build-and-install.sh` |

---

## Notas importantes

- **`cnf-bin/bin/`** no se despliega a `~/.config/`; instálalo en `/usr/local/bin` con los scripts de arriba o bien en ~/.local/bin.
- **Fondos:** destino `~/.config/fondos/`; deploy con `--fondos` o `--fondos-all` ([`shared/fondos/README.md`](shared/fondos/README.md)).
- **Documentación (`.md`)** permanece en el clone; `deploy-configs.sh` la excluye de `~/.config/`.
- **`thinkfan`**: no uses `sudo thinkfan`; el script llama sudo solo para el ventilador. Soporta modo cadena (`-c`/`-C`). Ver [`shared/cnf-bin/README.md`](shared/cnf-bin/README.md).
- **Rutas legacy**: algunos scripts aceptan el layout antiguo (`hyperland/` en raíz). La fuente canónica es `hyprland/hyperland/`, `shared/`, `I3/`.

---

## Licencia

Ver [`LICENSE`](LICENSE).
