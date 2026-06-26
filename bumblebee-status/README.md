# Bumblebee-status (podado)

Barra de estado para **i3/X11**. Copia reducida de [bumblebee-status](https://github.com/tobi-wan-kenobi/bumblebee-status) con solo los módulos y temas que uso.

> **Para después (i3):** la barra no se ha validado en sesión i3 tras la migración cnf-bin. Ver [`../cnf-bin/PENDING_I3.md`](../cnf-bin/PENDING_I3.md).

## Deploy

`deploy-configs.sh` copia esta carpeta a `~/.config/bumblebee-status/` **sin** `README.md` ni `images/` (iconos PNG de referencia; solo en el repo).

## Lanzamiento

Usar [`launch.sh`](launch.sh) (lee [`../cnf-bin/config.toml`](../cnf-bin/config.toml)):

```bash
# En i3-wm/conf.d/05-bbar.conf
status_command ~/.config/bumblebee-status/launch.sh
```

Módulos en barra (sin `cmus`):

```text
media cpu sensors memory disk battery pipewire brightness keyboard hostname datetime shell:kbd
```

`shell:kbd` → `cnf-info --kbdlight` (solo lectura).

## Módulos conservados

**core:** `media`, `cpu`, `memory`, `disk`, `datetime`, `keyboard`, `error`

**contrib:** `sensors`, `battery`, `pipewire`, `brightness`, `hostname`, `shell`, `shortcut`, `cmus` (reserva; no en barra)

**temas:** `themes/iceberg.json`, `themes/icons/awesome-fonts.json`

**assets (solo repo):** `images/` — iconos PNG de referencia; no se despliegan a `~/.config/`

## Dependencias

Instalar bumblebee-status (AUR/pip) o usar el binario `bumblebee-status` incluido en esta carpeta.

```text
playerctl brightnessctl lm_sensors wireplumber python-psutil
```

`cnf-info` en PATH (`/usr/local/bin`).

## Instalación manual

```bash
./hyperland/scripts/deploy-configs.sh --config
# o copiar bumblebee-status/ → ~/.config/bumblebee-status/
chmod +x ~/.config/bumblebee-status/launch.sh ~/.config/bumblebee-status/bumblebee-status
```
