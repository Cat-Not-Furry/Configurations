# Hyprland – Configuración modular (Wayland)

Configuración personal de **Hyprland** en módulos: keybinds, gestos, Waybar, Wofi, Ignis, swaync, temas unificados.

## Estructura en el repo

```
hyperland/
├── hyprland.conf          # Sources principales
├── hypridle.conf
├── hyprlock.conf
├── conf.d/                # Fragmentos de config
│   ├── vars.conf
│   ├── monitors.conf
│   ├── exec.conf
│   ├── keybinds.conf
│   └── ...
├── scripts/               # Despliegue, temas, utilidades
│   ├── deploy-configs.sh
│   ├── apply-theme.sh
│   ├── wofi-launch.sh
│   └── lib/
├── themes/
│   ├── palettes.json
│   └── palettes.example.json
└── swaync/
    └── config.json
```

En el sistema, la config activa vive en `~/.config/hypr/` (sin este README ni otros `.md`).

## Probar la configuración

```bash
# Clonar (ejemplo — usa tu URL)
git clone https://github.com/TU_USUARIO/TU_REPO.git dotfiles
cd dotfiles

# Backup opcional
[ -d ~/.config/hypr ] && cp -r ~/.config/hypr ~/.config/hypr.bak

# Desplegar stack completo → ~/.config/ + ~/Games/configurations
./hyperland/scripts/deploy-configs.sh
```

El script resuelve rutas **relativas al clone** (`waybar/`, `wofi/`, `ignis/`, `cava/` como carpetas hermanas de `hyperland/`).

> **Documentación solo en el repo:** `README.md`, `docs/` y demás `.md` **no** se copian a `~/.config/`. Quedan en el clone (`~/hyprland` o `~/Games/configurations`).

### Despliegue manual (sin script)

Desde la raíz del clone:

```bash
cp -r hyperland/conf.d hyperland/hyprland.conf hyperland/hypridle.conf hyperland/hyprlock.conf ~/.config/hypr/
cp -r hyperland/scripts ~/.config/hypr/
cp -r hyperland/swaync ~/.config/
chmod +x ~/.config/hypr/scripts/*.sh

cp -r waybar wofi ignis cava ~/.config/
mkdir -p ~/.config/ignis/themes
cp hyperland/themes/palettes.json ~/.config/ignis/themes/

./hyperland/scripts/apply-theme.sh blue
hyprctl reload
```

## Requisitos

### Esenciales

- `hyprland`, `waybar`, `wofi`, `ignis`
- `swaync` (notificaciones), `polkit-kde-agent` o similar
- `brightnessctl`, `playerctl`, `pipewire` / `wireplumber`
- `xdg-desktop-portal`, `xdg-desktop-portal-hyprland`
- `hypridle`, `hyprlock` (según `exec.conf`)

### Opcionales

- `swww` / `awww` — fondos estáticos
- `mpvpaper` — fondos en video
- `cava` — visualizador en Waybar
- `flameshot`, `copyq`, `hyprsunset`

### Arch Linux (ejemplo)

```bash
sudo pacman -S hyprland waybar wofi brightnessctl playerctl \
  xdg-desktop-portal xdg-desktop-portal-hyprland polkit-kde-agent \
  hypridle hyprlock foot
# swaync, ignis: según repos / AUR de tu instalación
```

## Bandeja del sistema (nm-applet, Bluetooth, CopyQ)

Los iconos van en el módulo `tray` de Waybar. Se lanzan **después** de waybar (`StatusNotifierWatcher`).

| Momento | Script |
|---------|--------|
| Login Hyprland | `scripts/hypr-session-init.sh` — portales, polkit, swaync |
| ~8 s después | `scripts/ensure-tray-services.sh` — nm-applet, blueman-applet, copyq |
| Deploy / apply-theme | `scripts/lib/service-reload.sh` — relanza bandeja tras waybar |

Config: `conf.d/exec.conf`, módulo `tray` al **final** de `modules-right` en `waybar/config`.

## Ajustes tras instalar

Edita en el **repo** (luego `deploy-configs.sh --config`):

| Archivo en el repo | Qué cambiar |
|--------------------|-------------|
| `hyperland/conf.d/monitors.conf` | Salidas (`hyprctl monitors`) |
| `hyperland/hyprlock.conf` | Imagen de bloqueo |
| `hyperland/scripts/wofi_wallpaper.sh` | `STATIC_WALL_DIR`, `VIDEO_WALL_DIR` |
| `hyperland/conf.d/keybinds.conf` | Terminal (`foot` → la tuya) |

## Temas

13 temas en `themes/palettes.json` (blue, green, tokyo_night, catppuccin_mocha, …).

```bash
# Desde la raíz del clone
./hyperland/scripts/apply-theme.sh tokyo_night
```

También: botón **Tema** en Ignis, o `Super+Shift+R` (`hypr-refresh.sh`) para recargar servicios.

`apply-theme.sh` actualiza Hypr, Waybar, Wofi, Cava, Tmux, Nvim y Powerline en `~/.config/` únicamente.

Regenerar assets en el repo (mantenedores):

```bash
./hyperland/scripts/generate-wofi-wayland.sh
./hyperland/scripts/generate-cava-wayland.sh
./hyperland/scripts/generate-tmux-colors.sh
```

## Entornos Hyprland vs i3/X11

| Script | Función |
|--------|---------|
| `x11-environment.sh` | Bash X11, env GTK/Qt, cava X11 |
| `hypr-environment.sh` | Bash Hypr + powerline, cava wayland |

```bash
./hyperland/scripts/x11-environment.sh
source ~/.bashrc
```

## Tmux

Manual en foot; alias `tm`. Prefijo **Alt+a**. Atajos: `./hyperland/scripts/tmux-atajos.sh`.

Barra: usuario, host, contadores pacman/AUR/flatpak (cache 1 h), hora. Sin TPM.

## Atajos útiles

| Atajo | Acción |
|-------|--------|
| `Super+D` | Wofi drun |
| `Super+Shift+S` | Menú apagar / suspender |
| `Super+Shift+A` | Menú apps / juegos / utilidades |
| `Super+Shift+R` | Recarga Hypr + servicios |

Ver `conf.d/keybinds.conf` para la lista completa.

## Scripts principales

| Script | Función |
|--------|---------|
| `deploy-configs.sh` | Copia stack → `~/.config/` (+ mirror por defecto); `--config` solo config; `--all` + swaync |
| `apply-theme.sh` | Tema activo en Hypr / Waybar / Wofi / Cava / Tmux / Nvim |
| `x11-environment.sh` | Perfil shell + cava para sesión i3/X11 |
| `hypr-environment.sh` | Restaurar perfil Wayland |
| `ensure-tray-services.sh` | Bandeja nm-applet / blueman / copyq (tras waybar) |
| `tmux-atajos.sh` | Referencia de atajos tmux (terminal) |
| `toggle-waybar-position.sh` | Barra arriba / abajo |
| `wofi-launch.sh` | Wofi con estilo del tema |
| `hypr-refresh.sh` | Reload + reinicio de servicios |

## Gestos (`conf.d/gestures.conf`)

- 4 dedos ←/→: cambiar workspace
- 3 dedos: mover foco
- 4 dedos ↑: fullscreen; ↓: flotante

Requiere `libinput-gestures` y usuario en grupo `input`.

## Solución de problemas

- **Hyprland no arranca:** ejecuta `Hyprland` en TTY y revisa `hyprctl errors`.
- **Gestos:** comprueba `libinput-gestures` y permisos.
- **Servicios duplicados:** usa `./hyperland/scripts/hypr-refresh.sh` o `deploy-configs.sh`.
- **Waybar sin colores:** ejecuta `apply-theme.sh`.

## Notas

- Estructura modular: edita un archivo en `conf.d/` en lugar del monolito.
- `wofi-script1.sh` incluye entradas para mame, gzdoom, etc.; comenta lo que no uses.
- El deploy por defecto ya sincroniza `~/hyprland` → `~/Games/configurations` (mirror local). Usa `--config` si solo quieres actualizar `~/.config/`.
