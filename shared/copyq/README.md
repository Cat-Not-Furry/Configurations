# copyq

Gestor de portapapeles con historial y temas sincronizados con la palette del escritorio.

## Instalación

```bash
./hyprland/scripts/install-hypr.sh
./I3/scripts/install-i3.sh
```

Destino: `~/.config/copyq/`

## Temas

| Entorno | Script |
|---------|--------|
| **Hyprland** | `generate-copyq-themes.sh` + `apply-theme.sh` |
| **i3 / X11** | `apply-i3-theme.sh` → palette `classic` o `blue` (iceberg) |

Generación desde palette Hyprland:

```bash
./hyprland/hyperland/scripts/generate-copyq-themes.sh
```

Temas incluidos en repo: catppuccin, tokyo-night, blue, etc.

## Requisitos

```bash
sudo pacman -S copyq
```

## i3 / Hyprland

- i3: autostart vía `ensure-tray-services.sh` y reglas en `conf.d/`
- Hyprland: bandeja en waybar + exec en `conf.d/exec.conf`

Toggle rápido i3: `I3/i3-wm/scripts/copyq-toggle.sh`
