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

**No uses `sudo thinkfan`** — el script llama sudo solo para escribir en el interfaz del ventilador.

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

Estado y log: `~/.cache/cnf-bin/thinkfan/`

---

## Otros scripts en `bin/`

| Script | Uso |
|--------|-----|
| `sdm` | Selector de sesión (i3 / Hyprland / apagar) |
| `docker-manager` | Entorno Docker / Laravel |
| `web-manager` | Apache + MariaDB |
| `print-manager` | CUPS / impresión |
| `actualizar` | Actualización Arch interactiva |
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

Deploy incluido en `deploy-configs.sh`; **bin/** no se copia a `~/.config/`.

---

## Dependencias

```text
playerctl brightnessctl lm_sensors wireplumber
```

Rust (solo compilar): `cnf-info`, `cnf-media`
