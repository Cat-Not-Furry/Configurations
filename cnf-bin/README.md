# cnf-bin

Scripts de uso diario, binario `cnf-info` y configuración centralizada.

- **Fuente en repo:** `cnf-bin/bin/` (en `~/Games/configurations`; no se copia a `~/.config`)
- **Runtime:** instalar en `/usr/local/bin` (manual)
- **Config deploy:** `~/.config/cnf-bin/` (`config.toml`, `secrets/`, `apps/`)

## PATH

Tras `sudo install` en `/usr/local/bin` y `source ~/.bashrc`:

```text
/usr/local/bin                              # cnf-info, sdm, thinkfan, …
~/Games/configurations/utilidades           # monitor, cpu-mode, … (PATH al clone)
```

## Deploy

Incluido en `./hyperland/scripts/deploy-configs.sh`:

| Origen | Destino |
|--------|---------|
| `cnf-bin/bin/*` | — (no se despliega; usar `/usr/local/bin`) |
| `config.toml` | `~/.config/cnf-bin/config.toml` |
| `secrets/*.example` | `~/.config/cnf-bin/secrets/` |
| `apps/` | directorios bajo `~/.config/cnf-bin/apps/` |

**No** se sobrescribe `~/.config/cnf-bin/config.local.toml` si ya existe.

### Instalar binarios en `/usr/local/bin`

```bash
./hyperland/scripts/install-local-binaries.sh
# o manual:
sudo install -m 755 ~/Games/configurations/cnf-bin/bin/* /usr/local/bin/
```

Quitar copias antiguas en `~/.config` (si un deploy previo las creó como root):

```bash
./hyperland/scripts/clean-runtime-binaries.sh
```

## Configuración

| Archivo | Uso |
|---------|-----|
| [`config.toml`](config.toml) | Maestro (versionado) |
| `config.local.toml` | Override local (gitignored; copiar desde [`config.local.toml.example`](config.local.toml.example)) |
| `secrets/*.env` | Credenciales (gitignored; ver `*.example`) |

Variables: `[brillo]`, `[kbdlight]`, `[bumblebee]`, `[paths]`, `[programs.*]`.

## cnf-info (Rust)

Sustituye los antiguos scripts separados `brillo`, `bateria`, `temperatura`, `frecuencia` y `waybar/scripts/kblight.sh`. **No existen** como archivos en `cnf-bin/bin/` — solo flags de `cnf-info`.

```bash
cnf-info                          # resumen HW (4 líneas, ANSI)
cnf-info --brillo [+ | - | 1-100]
cnf-info --bateria
cnf-info --temperatura
cnf-info --frecuencia
cnf-info --kbdlight               # solo lectura (Waybar / bumblebee shell:kbd)
```

Compilar:

```bash
cd cnf-bin/cnf-info
CARGO_TARGET_DIR=./target cargo build --release
cp target/release/cnf-info ../bin/cnf-info
```

## Scripts en `bin/`

`sdm`, `thinkfan`, `fondo`, `life_fondo`, `bgterm`, `docker-manager`, `web-manager`, `print-manager`, `git-configure`, `git-push`, `actualizar`, `toggle-keyboard.sh`, `dead_fondo.sh`, etc.

Managers usan `cnf-bin/apps/<nombre>/` para logs y estado. `web-manager` lee `secrets/web-manager.env`.

## Dependencias (pacman)

```text
playerctl brightnessctl lm_sensors wireplumber python-psutil
```

Rust (solo para compilar `cnf-info`): `cargo`, `rustc`.

## Más información

- [`TROUBLESHOOTING.md`](TROUBLESHOOTING.md) — pruebas y diagnóstico
- [`PENDING_I3.md`](PENDING_I3.md) — validación pendiente en i3/X11
- [`MIGRATION.md`](MIGRATION.md) — historial de migración
- [`CLOSURE.md`](CLOSURE.md) — checklist de cierre fase F

## utilidades

Scripts opcionales en [`../utilidades/`](../utilidades/) (monitor, cpu-mode, …). **No** se despliegan; el PATH apunta al clone.
