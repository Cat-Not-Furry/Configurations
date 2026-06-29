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

## Generación de temas Wayland

Desde el repo Hyprland:

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
