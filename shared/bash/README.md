# bash

Fragmentos de shell para cargar desde `~/.bashrc` según la sesión gráfica.

## Archivos

| Archivo | Sesión |
|---------|--------|
| `bashrc.x11` | i3 / X11 |
| `bashrc.hypr` | Hyprland / Wayland |

Incluyen PATH a `shared/utilidades`, aliases y powerline (Hypr).

## Instalación

Se despliegan con el stack correspondiente:

```bash
./I3/scripts/install-i3.sh
./hyprland/scripts/install-hypr.sh
```

Destino: `~/.config/bash/`

Enlaza o incluye desde tu `~/.bashrc` personal (ver comentarios en cada archivo).

## Notas

- No sustituye tu `.bashrc` completo; son includes modulares.
- `session/README.md` documenta `sdm` y entorno de consola.
