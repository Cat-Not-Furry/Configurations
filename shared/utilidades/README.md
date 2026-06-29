# utilidades

Scripts auxiliares instalables en `/usr/local/bin` vía `install-local-binaries.sh` o `./shared/install.sh --binaries`.

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

Tras instalar binarios y cargar bashrc:

```bash
which monitor cpu-mode    # /usr/local/bin si usaste --binaries
```

También disponibles desde el clone vía [`bash/bashrc.hypr`](../bash/bashrc.hypr) si no instalaste en `/usr/local/bin`.

## Dependencias (pacman)

```text
playerctl brightnessctl lm_sensors wireplumber python-psutil
```

(`python-psutil` para `monitor`; el resto según script.)
