# tmux

Configuración tmux con temas alineados a las palettes del repo.

## Instalación

```bash
./hyprland/scripts/install-hypr.sh
./I3/scripts/install-i3.sh
```

Destino: `~/.config/tmux/` (o enlace según deploy)

## Temas

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
