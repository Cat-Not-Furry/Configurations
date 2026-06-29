# powerline (Hyprland)

Segmentos y tema **powerline-shell** para la sesión Hyprland (`bashrc.hypr`).

## Contenido

```
powerline/
├── config.json           # Config powerline-shell
├── colorschemes/shell/   # Esquemas (hypr.json, …)
└── hypr_segments/        # Segmentos Python (docker, etc.)
```

## Instalación

Se despliega automáticamente con el stack Hyprland (no con i3):

```bash
./hyprland/scripts/install-hypr.sh
```

Destino: `~/.config/powerline/`

## Requisitos

```bash
sudo pacman -S powerline-shell python
# Segmentos opcionales según hypr_segments/
```

## Bash

El fragmento [`shared/bash/bashrc.hypr`](../shared/bash/bashrc.hypr) activa powerline en sesiones Hyprland.

## Notas

- Solo Hyprland: `deploy-configs.sh --config-i3` omite powerline.
- Documentación no se copia a `~/.config/`.
