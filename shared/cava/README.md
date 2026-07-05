# cava

Visualizador de audio en terminal, con configs para **X11** e **Wayland**.

## Estructura

```
cava/
├── wayland/          # Configs por tema (generadas / temáticas)
├── themes/           # Temas base
└── shaders/          # Shaders opcionales
```

## Instalación

```bash
./hyprland/scripts/install-hypr.sh    # Wayland
./I3/scripts/install-i3.sh            # X11 (vía i3-environment.sh)
```

Destino: `~/.config/cava/`

## Temas

| Entorno | Activación |
|---------|------------|
| **Hyprland** | `apply-theme.sh [theme_id]` |
| **i3 / X11** | `apply-i3-theme.sh` (lee `[i3] theme` en `cnf-bin/config.toml`) |

En X11 se copia `wayland/config.{slug}` o `x11/config.txt` según la palette (`classic` o `blue` para iceberg).

Generación desde palette Hyprland:

```bash
./hyprland/hyperland/scripts/generate-cava-wayland.sh
./hyprland/hyperland/scripts/apply-theme.sh [theme_id]
```

## Requisitos

```bash
sudo pacman -S cava
```

## Uso

- Waybar: módulo `custom/cava` (Hyprland)
- Terminal: `cava` o `bgterm cava`
