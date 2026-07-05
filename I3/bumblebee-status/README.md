# Bumblebee-status (podado)

Barra de estado para **i3/X11**. Media vía `cnf-media`; HW vía `cnf-info`.

## Deploy

`deploy-configs.sh` copia esta carpeta a `~/.config/bumblebee-status/` **sin** `README.md` ni `images/` (iconos PNG de referencia; solo en el repo).

## Lanzamiento

Usar [`launch.sh`](launch.sh) (lee [`../../shared/cnf-bin/config.toml`](../../shared/cnf-bin/config.toml)):

```bash
# En i3-wm/conf.d/05-bbar.conf
status_command ~/.config/bumblebee-status/launch.sh
```

Módulos en barra (config completa):

```text
media cpu sensors memory disk battery pipewire brightness kbdlight keyboard hostname datetime
```

| Módulo | Fuente | Información mostrada |
|--------|--------|----------------------|
| `media` | **cnf-media** | ⏮ título/artista ⏭ (MPRIS) |
| `cpu` | psutil | Uso CPU `{:.01f}%` |
| `sensors` | lm_sensors / sysfs | Temperatura (+ frecuencia si activo) |
| `memory` | `/proc/meminfo` | `{used}/{total} ({percent}%)` |
| `disk` | `statvfs` | `{used}/{size} ({percent}%)` en `/` |
| `battery` | UPower | `%` + icono carga |
| `pipewire` | `wpctl` | Volumen `%` (scroll para ajustar) |
| `brightness` | brightnessctl | Brillo pantalla `%` |
| `kbdlight` | sysfs LED | Luz teclado `%` (lee `[kbdlight]` en config.toml) |
| `keyboard` | xinput | Layout / toggle teclado |
| `hostname` | `platform.node` | Nombre del equipo |
| `datetime` | strftime | Fecha y hora completas (`%x %X`) |

Waybar (Hyprland) usa **cnf-info** para CPU/temp; bumblebee usa módulos Python propios con el mismo tipo de datos.

## Módulos conservados

**core:** `media`, `cpu`, `memory`, `disk`, `datetime`, `keyboard`, `error`

**contrib:** `sensors`, `battery`, `pipewire`, `brightness`, `kbdlight`, `hostname`, `shell`, `shortcut`, `cmus` (reserva; no en barra)

**temas:** `themes/classic.json`, `themes/iceberg.json`, `themes/icons/awesome-fonts.json`

**assets (solo repo):** `images/` — iconos PNG de referencia; no se despliegan a `~/.config/`

## Dependencias

Instalar bumblebee-status (AUR/pip) o usar el binario `bumblebee-status` incluido en esta carpeta.

```text
playerctl brightnessctl lm_sensors wireplumber python-psutil
```

`cnf-info` en PATH (`/usr/local/bin`).

## Instalación manual

```bash
./I3/scripts/deploy-i3.sh
# o copiar bumblebee-status/ → ~/.config/bumblebee-status/
chmod +x ~/.config/bumblebee-status/launch.sh ~/.config/bumblebee-status/bumblebee-status
```
