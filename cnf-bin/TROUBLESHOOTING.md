# Depuración cnf-bin — fase E (2026-06-26)

Registro de pruebas Hyprland + TTY. i3/X11 **no** probados en runtime.

## TTY / shell

| Caso | Resultado | Notas |
|------|-----------|-------|
| `cnf-info` (4 líneas ANSI) | OK | batería, temp, freq, brillo |
| `cnf-info --brillo` | OK | % + ayuda stderr |
| `cnf-info --brillo +` / `-` | OK | 10% → 12% → 10% |
| `--bateria`, `--temperatura`, `--frecuencia` | OK | ANSI |
| `cnf-info --kbdlight` | OK | Vacío con luz apagada (nivel 0); iconos con nivel 1/2 |
| `config.local.toml` merge | OK | `[brillo].device` cargado sin pisar `config.toml` |
| `web-manager` / `docker-manager` | OK | `bash -n`; secrets desde `~/.config/cnf-bin/secrets/web-manager.env` |
| `sdm --help` | OK | |
| `thinkfan` | OK | Muestra ayuda de perfiles |

## Hyprland

| Caso | Resultado | Notas |
|------|-----------|-------|
| `deploy-configs.sh --config` | OK | Ver fase D; re-deploy preserva `config.local.toml` |
| Waybar `custom/kblight` | OK | `exec` → `cnf-info --kbdlight` |
| Atajos brillo | OK | `keybinds.conf` → `cnf-info --brillo +/-` |
| `config.local.toml` tras deploy | OK | No sobrescrito por `copy_cnf_bin_assets` |
| Secrets en git | OK | Solo `*.example` en repo; `.gitignore` para `*.env` |
| Tema tras deploy | OK | `apply-theme` completa (waybar + hypr reload) |
| `wb_autohide` binario | OK | `~/.config/waybar/scripts/bin/wb_autohide` ejecutable |
| Daemon autohide | OK | `wb_autohide --side top` visible en `pgrep`; `stop` limpia |
| `waybar-autohide.sh` | OK | `WAYBAR_AUTOHIDE_DAEMON_NAME=wb_autohide` (sin legacy `waybar_auto_hide`) |

## PATH

Tras `source ~/.bashrc` (bashrc.hypr desplegado):

- `/usr/local/bin` en PATH (binarios cnf-bin)
- Clone `~/Games/configurations/utilidades` si existe el repo

## Regresiones vigiladas

| Riesgo | Estado |
|--------|--------|
| `brightnessctl` pantalla vs kbd mezclados | OK | `--brillo` sin `--device` kbd; `[kbdlight]` separado |
| Waybar kblight congela barra | No observado | `interval: 3` |
| Fondos i3 borrados en deploy | OK | merge sin `--delete` |

## Pendiente i3/X11

Ver [PENDING_I3.md](PENDING_I3.md).

## Si algo falla

1. `which cnf-info` → debe resolver a `/usr/local/bin/cnf-info`
2. Re-deploy: `./hyperland/scripts/deploy-configs.sh --config`
3. Waybar: `pkill waybar; waybar &` o `hypr-refresh.sh`
4. Autohide: `~/.config/waybar/scripts/bin/wb_autohide` o `which wb_autohide`; toggle `^`/`v` en barra
