# cnf-bin

Scripts de uso diario, binarios Rust (`cnf-info`, `cnf-media`) y configuración centralizada.

- **Fuente en repo:** `shared/cnf-bin/bin/`
- **Runtime:** `/usr/local/bin` (manual o vía install scripts)
- **Config deploy:** `~/.config/cnf-bin/`

## Instalación

```bash
# Config + binarios (desde shared/)
./shared/install.sh

# Compilar Rust + instalar todo
./shared/cnf-bin/build-install.sh

# Como parte de un stack
./hyprland/scripts/install-hypr.sh --binaries
./I3/scripts/install-i3.sh --binaries
```

## PATH

```text
/usr/local/bin
~/Games/configurations/shared/utilidades   # vía bashrc
```

## Usuario de sesión y sudo

Scripts que llaman `sudo` internamente (`actualizar`, `hostname-nm`, `thinkfan`, `*-manager`, etc.) deben ejecutarse **como tu usuario**, no con `sudo ./script`.

- `lib/require-session-user.sh` — si alguien hace `sudo ./script`, re-lanza como `SUDO_USER`.
- `lib/bootstrap-session-user.sh` — lo usan binarios en `/usr/local/bin` para encontrar esa lib.

Tras deploy, las libs viven en `~/.config/cnf-bin/lib/`. Si falta, ejecuta `./shared/install.sh --config-only`.

---

## cnf-info

Resumen de hardware (batería, temperatura, CPU, brillo, luz teclado):

```bash
cnf-info
cnf-info --brillo [+ | - | 1-100]
cnf-info --kbdlight
cnf-info --bateria | --temperatura | --frecuencia
```

### Waybar (refresh + cache)

```bash
cnf-info --refresh
cnf-info --widget cpu --cached --json
cnf-info --widget temp --cached --json
cnf-info --widget battery --cached --json   # opcional; Waybar usa battery nativo
```

Cache: `~/.cache/cnf-bin/hw.json`. Módulo oculto `custom/hw-refresh` en waybar (interval 3 s).

## cnf-media

Control MPRIS vía `playerctl` (Waybar, bumblebee):

```bash
cnf-media --refresh
cnf-media --widget main --cached
cnf-media --list-players
cnf-media --play-pause
```

Config en `[media]`: `prefer_players` incluye `zen-browser`, `zen`.

---

## thinkfan

Control **temporal** del ventilador en ThinkPad (`/proc/acpi/ibm/fan`).

**No uses `sudo thinkfan`** — si lo haces por error, el script se re-lanza como tu usuario (`bootstrap-session-user`). El `sudo` interno agrupa escrituras en `/proc/acpi/ibm/fan` (un prompt por lote, no tres seguidos).

Antes de cambiar de perfil conviene `thinkfan stop`. El worker corre en segundo plano; no hace falta dejar la terminal abierta (puedes usar tmux u otra ventana auxiliar).

Estado, log y bus de sesión para notificaciones: `~/.cache/cnf-bin/thinkfan/` (`thinkfan.env` guarda `DBUS_SESSION_BUS_ADDRESS` al lanzar desde una sesión gráfica).

Si quedaron restos de versiones antiguas o workers root: `thinkfan cleanup`.

Opcional avanzado (sin huella en cada refresco del ventilador): en `/etc/sudoers.d/thinkfan`:

```text
tu_usuario ALL=(root) NOPASSWD: /usr/bin/tee /proc/acpi/ibm/fan
```

### Modo simple

```bash
thinkfan cool -t 120              # 120 segundos (mín. 5 s)
thinkfan turbo -t infinity        # hasta thinkfan stop
thinkfan status
thinkfan stop
```

### Modo cadena (`-c` / `-C`)

Cada perfil dura `-t` segundos; luego pasa al siguiente. Mínimo **30 s por paso**. No admite `infinity`.

```bash
thinkfan -c cool -t 120
thinkfan cool -C turbo -C idle -t 45
thinkfan status    # muestra paso actual y restante total
```

Perfiles: `idle`, `cool`, `dev`, `turbo`, `overdrive`

Estado y log: `~/.cache/cnf-bin/thinkfan/` (ver notas arriba sobre `thinkfan.env` y `cleanup`)

---

## Otros scripts en `bin/`

| Script | Uso |
|--------|-----|
| `sdm` | Selector de sesión (i3 / Hyprland / apagar) |
| `docker-manager` | Entorno Docker / Laravel |
| `web-manager` | Apache + MariaDB |
| `print-manager` | CUPS / impresión |
| `actualizar` | Actualización Arch interactiva |
| `hostname-nm` | Cambiar hostname vía NetworkManager |
| `thinkfan` | Control ventilador ThinkPad (fuente en `bin/thinkfan`) |
| `fondo` / `life_fondo` | Fondos i3 |
| `bgterm` | Terminal como fondo (cava, btop) |
| `git-push` / `git-configure` | Utilidades git |

---

## Configuración

| Archivo | Uso |
|---------|-----|
| [`config.toml`](config.toml) | Maestro |
| `config.local.toml` | Override local (gitignored) |
| `secrets/*.env` | Credenciales managers (desde `.example`) |

Secciones: `[brillo]`, `[kbdlight]`, `[media]`, `[bumblebee]`, `[i3]`, `[session.x11]`, `[session.wayland]`, `[paths]`.

`[paths] fondos` apunta a `~/.config/fondos/` (comando `fondo`, Ignis, Hyprlock). El deploy no copia wallpapers salvo `--fondos` / `--fondos-all` — ver [fondos/README.md](../fondos/README.md).

Deploy incluido en `deploy-configs.sh`; **bin/** no se copia a `~/.config/`.

---

## Dependencias

```text
playerctl brightnessctl lm_sensors wireplumber
```

Rust (solo compilar): `cnf-info`, `cnf-media`
