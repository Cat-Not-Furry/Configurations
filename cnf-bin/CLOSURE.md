# Cierre movimiento cnf-bin (fase F)

Checklist para validar que el repo está listo para clonar en otra máquina. Hyprland validado en fases D–E; i3 queda como prueba manual futura.

## Checklist

- [ ] **Clone fresco** + `./hyperland/scripts/deploy-configs.sh` (o `--config` solo para `~/.config`) → Waybar arranca sin errores en Hyprland
- [ ] **`cnf-info` en PATH** — `which cnf-info` → `/usr/local/bin/cnf-info`
- [ ] **Autohide Waybar** — `wb_autohide` desplegado en `~/.config/waybar/scripts/bin/`
- [ ] **Documentación** — sin referencias a scripts borrados (`session/binscripts/brillo`, `kblight.sh`, etc.)
- [ ] **`config.local.toml`** — copiar desde `config.local.toml.example`; no versionado (`.gitignore`)
- [ ] **Repo** — `~/Games/configurations` con `cnf-bin/`, `utilidades/`, bumblebee podado, `deploy-configs.sh` actualizado

## Pendiente i3/X11

Ver [`PENDING_I3.md`](PENDING_I3.md) y [`../i3-wm/README.md`](../i3-wm/README.md): barra bumblebee vía `launch.sh`, atajos de brillo con `cnf-info`. **No probado en runtime.**

## Estado fase F (2026-06-12)

| Tarea | Estado |
|-------|--------|
| READMEs (cnf-bin, utilidades, bumblebee, raíz, i3) | Hecho |
| Borrado legacy HW + `kblight.sh` | Hecho |
| `.gitignore` secrets + `config.local.toml` | Hecho |
| Repo único `~/Games/configurations` | Hecho (2026-06-26) |
| Movimiento cnf-bin | **Cerrado** (Hyprland); i3 manual |

## Referencias

- [`README.md`](README.md) — uso diario
- [`MIGRATION.md`](MIGRATION.md) — historial A→F
- [`TROUBLESHOOTING.md`](TROUBLESHOOTING.md) — matriz de pruebas
