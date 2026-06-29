# Waybar – Configuración para Hyprland

Barra de estado para **Hyprland**: workspaces, media, CPU, temperatura, memoria, disco, volumen, brillo, batería, fecha y bandeja.

## Estructura en el repo

```
waybar/
├── config                 # JSON principal
├── style.css              # Estilos (importa waybar-colors.css)
├── waybar-colors.css      # Generado por apply-theme.sh en ~/.config/
└── scripts/
    ├── media.py           # Módulo multimedia (playerctl)
    ├── cmus_status.sh
    ├── temp_status.sh
    └── waybar_date_icon.sh
```

Tras desplegar, la copia activa queda en `~/.config/waybar/` (sin este README).

> **Documentación:** este archivo solo existe en el repo. `deploy-configs.sh` no copia `README.md` ni `docs/` a `~/.config/`.

## Instalación

### Opción recomendada (stack completo)

Desde la raíz del clone:

```bash
./hyprland/scripts/install-hypr.sh
./hyprland/scripts/install-hypr.sh --binaries
```

Requiere `cnf-info` en PATH (`/usr/local/bin` tras `--binaries`).

Módulos HW vía `cnf-info --refresh` + `--widget cpu|temp --cached --json` (ver [`shared/cnf-bin/README.md`](../shared/cnf-bin/README.md)).

### Solo Waybar

```bash
[ -d ~/.config/waybar ] && mv ~/.config/waybar ~/.config/waybar.bak
./hyprland/scripts/install-hypr.sh
./hyprland/hyperland/scripts/apply-theme.sh blue
```

Waybar se inicia desde `hyperland/conf.d/exec.conf` si usas el stack Hyprland completo.

## Dependencias

| Paquete | Uso |
|---------|-----|
| `waybar` | Barra |
| `playerctl` | Módulos `custom/media-*` |
| `cmus` | Módulo `custom/cmus` (opcional) |
| `cava` | Visualizador (opcional) |
| `brightnessctl`, `pamixer` | Brillo y volumen |
| `lm_sensors` | Temperatura |
| `ttf-hack-nerd` o similar | Iconos Nerd Font |

**Arch Linux (ejemplo):**

```bash
sudo pacman -S waybar playerctl cmus cava brightnessctl pamixer lm_sensors ttf-hack-nerd
```

`cnf-info` (crate en `cnf-bin/`) para kbdlight y atajos de brillo en Hypr.

## Módulos destacados

### Izquierda

- `custom/launcher` — icono distro → Wofi drun
- `hyprland/workspaces`, `hyprland/window`

### Centro

- `custom/cmus` — reproductor cmus (opcional)
- `custom/cava` — visualizador (opcional)

### Derecha

- `custom/media-*` — playerctl
- `cpu`, `custom/temp`, `memory`, `disk`, `pulseaudio`, `backlight`, `battery`
- `custom/kblight` — `cnf-info --kbdlight` (solo lectura)
- `custom/hostname`, `custom/date`, `custom/bar-position`, `custom/bar-autohide`, `tray` (bandeja al final)

### Autohide (`wb_autohide`)

- Módulo `custom/bar-autohide`: `-` normal, `^`/`v` autohide
- Binario: `~/.config/waybar/scripts/bin/wb_autohide` (deploy desde `waybar/scripts/bin/`)
- Compilar: `cd waybar_auto_hide && cargo build --release && cp target/release/wb_autohide ../waybar/scripts/bin/wb_autohide`
- Alternativa: `/usr/local/bin/wb_autohide` vía `install-local-binaries.sh`
- Toggle en barra; ver `hyperland/scripts/toggle-waybar-autohide.sh`

## Ajustes habituales

- **Batería:** nombre en `config` (default `BAT0`) — `ls /sys/class/power_supply/`
- **Luz teclado:** `[kbdlight]` en `cnf-bin/config.toml`; no usar script legacy
- **Monitor / HDMI:** `hyperland/conf.d/monitors.conf` — `hyprctl monitors`

## Temas y colores

```bash
./hyperland/scripts/apply-theme.sh [theme_id]
```

Fuente de verdad: `hyperland/themes/palettes.json`.

## Solución de problemas

- **Waybar no arranca:** ejecútalo en terminal y revisa JSON en `config`.
- **kblight vacío:** normal con luz apagada; `cnf-info --kbdlight` en terminal.
- **Módulo vacío:** prueba el script a mano, p. ej. `~/.config/waybar/scripts/media.py --widget=main`.
- Ver [`shared/cnf-bin/README.md`](../shared/cnf-bin/README.md).

## Notas

- Pensado para **Hyprland**.
- Clic en fecha abre calendario en terminal (`alacritty` en `config`); cámbialo por tu emulador.
