# tmux

Configuración tmux con temas alineados a las palettes del repo.

## Instalación

```bash
./hyprland/scripts/install-hypr.sh
./I3/scripts/install-i3.sh
```

Destino: `~/.config/tmux/` (o enlace según deploy)

## Temas

| Entorno | Script | Mapeo i3 |
|---------|--------|----------|
| **Hyprland** | `apply-theme.sh [theme_id]` | — |
| **i3 / X11** | `apply-i3-theme.sh` + `activate_x11_shared_themes` | `classic`→`classic`, `iceberg`→`blue` |

En X11, tmux usa `colors/classic.conf` o `colors/gray.conf` según el tema i3 (`config.toml` `[i3] theme`).

Colores por palette en `colors/` y `colors/*.conf`. Regenerar desde Hyprland:

```bash
./hyprland/hyperland/scripts/generate-tmux-colors.sh
./hyprland/hyperland/scripts/apply-theme.sh [theme_id]
```

## Plugins (TPM)

Si usas TPM, instala plugins desde la sesión tmux: `prefix + I`

Ver `scripts/atajos.sh` para atajos documentados.

## Requisitos

```bash
sudo pacman -S tmux
```
