# utilidades

Scripts auxiliares fuera de `cnf-bin/`. **No se despliegan** con `deploy-configs.sh`; el PATH los añade desde el clone vía [`bash/bashrc.hypr`](../bash/bashrc.hypr).

Esta carpeta es **opcional**: puedes borrarla entera si no usas estas herramientas.

## Contenido

| Script | Descripción |
|--------|-------------|
| `monitor` | Configuración de pantallas múltiples (X11/Wayland) |
| `monitor-wofi` | Selector de monitor con Wofi |
| `cpu-mode` | Perfiles de frecuencia CPU (`+` / `=` / `-`) |
| `emulator-manager` | Gestión de emuladores Android |
| `network-scanner.sh` | Escaneo de red local |

Origen: migrados desde `session/binscripts/` y `~/.local/bin` (fase C). Respaldo en `cnf-bin/backups/local-bin-20260612/`.

## PATH

Tras `source ~/.bashrc`, los scripts deben estar en PATH si existe el clone en `~/hyprland` o `~/Games/configurations`:

```bash
which monitor cpu-mode
```

## Dependencias (pacman)

```text
playerctl brightnessctl lm_sensors wireplumber python-psutil
```

(`python-psutil` para `monitor`; el resto según script.)
