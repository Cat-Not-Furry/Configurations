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
    ├── kblight.sh
    ├── temp_status.sh
    └── waybar_date_icon.sh
```

Tras desplegar, la copia activa queda en `~/.config/waybar/`.

## Instalación

### Opción recomendada (stack completo)

Desde la raíz del clone:

```bash
./hyperland/scripts/deploy-configs.sh
```

### Solo Waybar

```bash
# Backup opcional
[ -d ~/.config/waybar ] && mv ~/.config/waybar ~/.config/waybar.bak

# Desde la raíz del clone
cp -r waybar ~/.config/
chmod +x ~/.config/waybar/scripts/*.sh

# Colores del tema (requiere hyperland/themes/)
cp hyperland/themes/palettes.json ~/.config/ignis/themes/ 2>/dev/null || mkdir -p ~/.config/ignis/themes && cp hyperland/themes/palettes.json ~/.config/ignis/themes/
./hyperland/scripts/apply-theme.sh blue
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

## Ajustes habituales

Ejecuta desde tu sistema (no rutas del repo):

- **Batería:** nombre en `config` (default `BAT0`) — `ls /sys/class/power_supply/`
- **Teclado retroiluminado:** `scripts/kblight.sh` → variable `DEVICE`
- **Monitor / HDMI:** nombres en `hyperland/conf.d/monitors.conf` — `hyprctl monitors`

## Módulos

### Izquierda

- `custom/launcher` — icono distro → Wofi drun
- `hyprland/workspaces`, `hyprland/window`

### Centro

- `custom/cmus` — reproductor cmus (opcional)
- `custom/cava` — visualizador (opcional; puede estar comentado en `config`)

### Derecha

- `custom/media-prev`, `custom/media-main`, `custom/media-next` — playerctl
- `cpu`, `custom/temp`, `memory`, `disk`, `pulseaudio`, `backlight`, `battery`
- `custom/bar-position`, `custom/date`, `tray`

## Temas y colores

`waybar-colors.css` se genera en `~/.config/waybar/` al ejecutar:

```bash
./hyperland/scripts/apply-theme.sh [theme_id]
```

Fuente de verdad: `hyperland/themes/palettes.json`.

## Media y caracteres especiales

`scripts/media.py` escapa `&`, `<`, `>` en títulos antes de enviarlos a Waybar (Pango markup). Si añades módulos custom con texto de terceros, usa el mismo patrón (`html.escape`) o `"return-type": "json"`.

## Solución de problemas

- **Waybar no arranca:** ejecútalo en terminal y revisa JSON en `config`.
- **Módulo vacío:** prueba el script a mano, p. ej. `~/.config/waybar/scripts/media.py --widget=main`.
- **Iconos rotos:** instala Nerd Font y revisa `font-family` en `style.css`.
- **Otro compositor:** cambia `hyprland/*` por `sway/*` en `config`.

## Notas

- Pensado para **Hyprland**.
- Clic en fecha abre calendario en terminal (`alacritty` en `config`); cámbialo por tu emulador.
