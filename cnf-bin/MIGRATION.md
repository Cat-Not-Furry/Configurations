# Migración cnf-bin — inventario (fases A–F)

Generado: 2026-06-12. Historial de migración; uso diario en [`README.md`](README.md); checklist en [`CLOSURE.md`](CLOSURE.md).

## Respaldo

| Artefacto | Ubicación |
|-----------|-----------|
| Rama git | `backup/cnf-bin-20260612` en `~/Games/configurations` |
| Tag anotado | `backup/cnf-bin-20260612` (HEAD al crear respaldo) |
| Tarball | `~/Backups/configurations-cnf-bin-20260612.tar.gz` (~606M, incluye working tree) |

**Nota:** Repo principal de desarrollo: `~/Games/configurations` (GitHub `Configurations`).

## `session/binscripts/` (20 entradas)

| Script | Destino fase C | Notas |
|--------|----------------|-------|
| `actualizar` | `cnf-bin/bin/` | |
| `bgterm` | `cnf-bin/bin/` | |
| ~~`bateria`~~, ~~`brillo`~~, ~~`temperatura`~~, ~~`frecuencia`~~ | **`cnf-info`** | Sin scripts separados en `cnf-bin/bin/` |
| `cpu-mode` | `utilidades/` | |
| `docker-manager` | `cnf-bin/bin/` + `apps/docker-manager/` | |
| `fondo` | `cnf-bin/bin/` | |
| `git-configure` | `cnf-bin/bin/` | |
| `git-push` | `cnf-bin/bin/` | |
| `hostname-nm` | `cnf-bin/bin/` | |
| `life_fondo` | `cnf-bin/bin/` | |
| `monitor` | `utilidades/` | |
| `monitor-wofi` | `utilidades/` | |
| `print-manager` | `cnf-bin/bin/` + `apps/print-manager/` | |
| `sdm` | `cnf-bin/bin/` | |
| `thinkfan` | `cnf-bin/bin/` + `apps/thinkfan/` | |
| `web-manager` | `cnf-bin/bin/` + `apps/web-manager/` | Secrets en `secrets/web-manager.env` |
| `?` | — | Ayuda; no migrar |

## `~/.local/bin` (relevantes)

| Script | Destino |
|--------|---------|
| `toggle-keyboard.sh` | `cnf-bin/bin/` |
| `dead_fondo.sh` | `cnf-bin/bin/` |
| `emulator-manager` | `utilidades/` |
| `network-scanner.sh` | `utilidades/` |

## bumblebee-status

- **Estado actual:** ~137 módulos `.py`, ~39 temas JSON (190 archivos en árbol).
- **Objetivo fase D:** ~7 core + 8 contrib + 2 temas (`iceberg.json`, `icons/awesome-fonts.json`).
- **Barra actual** ([`i3-wm/conf.d/05-bbar.conf`](../i3-wm/conf.d/05-bbar.conf)): `-m media cmus cpu sensors memory disk battery pipewire brightness keyboard hostname datetime` — quitar `cmus` en fase D.
- **Conservar sin barra:** `cmus.py` (reserva).

## Waybar kblight

- **Antes:** `waybar/scripts/kblight.sh` (`brightnessctl --device=tpacpi::kbd_backlight`).
- **Ahora:** `cnf-info --kbdlight` en Waybar `custom/kblight` y bumblebee `shell:kbd`.
- Device por defecto en `config.toml` → `[kbdlight]`.

## Waybar autohide (`wb_autohide`)

| Concepto | Ruta / valor |
|----------|----------------|
| Binario en repo | `waybar/scripts/bin/wb_autohide` |
| Tras deploy | `~/.config/waybar/scripts/bin/wb_autohide` |
| Alternativa | `/usr/local/bin/wb_autohide` (install-local-binaries.sh) |
| Fuente Rust | `waybar_auto_hide/` (crate nested) |
| Daemon name | `WAYBAR_AUTOHIDE_DAEMON_NAME=wb_autohide` en [`waybar-autohide.sh`](../hyperland/scripts/lib/waybar-autohide.sh) |

## deploy-configs.sh

- `copy_cnf_bin_assets()` despliega config/secrets/apps; **no** copia `bin/` (runtime → `/usr/local/bin`)
- Sync mirror: `cnf-bin` incluye docs y scripts en `bin/` (sin binario `cnf-info` compilado); `waybar` incluye `scripts/bin/wb_autohide`
- `chmod` de `waybar/scripts/bin/wb_autohide` tras deploy y sync
- Preserva `config.local.toml` en destino si ya existe

## Fase C (2026-06-12) — completada

- Scripts fuente en [`cnf-bin/bin/`](../cnf-bin/bin/) (repo `~/Games/configurations`); runtime en `/usr/local/bin`
- Respaldo histórico `local-bin-20260612` eliminado (2026-06)
- Managers: `CONFIG_DIR` / `LOG_DIR` bajo `cnf-bin/apps/<nombre>/`
- `web-manager` lee [`secrets/web-manager.env`](secrets/web-manager.env) (gitignored)
- PATH en `bash/bashrc.hypr` y `bash/bashrc.x11` (`utilidades/` al clone; cnf-bin vía `/usr/local/bin`)

## Fase D (2026-06-12) — completada

- Bumblebee podado (~7 core + 8 contrib + 2 temas); `cmus.py` conservado sin barra
- [`bumblebee-status/launch.sh`](../bumblebee-status/launch.sh) lee `config.toml`
- Waybar `custom/kblight` → `cnf-info --kbdlight`
- i3 repo: `05-bbar.conf`, binds brillo → `cnf-info`

## Fase E (2026-06-12) — completada

- Matriz TTY + Hyprland en [`TROUBLESHOOTING.md`](TROUBLESHOOTING.md)
- Pendiente i3 en [`PENDING_I3.md`](PENDING_I3.md)

## Fase F (2026-06-12) — completada

- READMEs: cnf-bin, utilidades, bumblebee, raíz, i3-wm, waybar, session/binscripts
- **Borrado:** `session/binscripts/{brillo,bateria,temperatura,frecuencia,?}`, `waybar/scripts/kblight.sh`
- `.gitignore`: `config.local.toml`, `secrets/*.env`, `target/`, `apps/**/logs/`, `backups/`
- Repo único: `~/Games/configurations`
- Checklist: [`CLOSURE.md`](CLOSURE.md)
