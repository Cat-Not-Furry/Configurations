# Stack Hyprland (Wayland)

```
hyprland/
├── hyperland/      → ~/.config/hypr/
├── waybar/         → ~/.config/waybar/
├── powerline/      → ~/.config/powerline/  (solo Hypr)
└── scripts/
    └── install-hypr.sh
```

Componentes compartidos: [`../shared/`](../shared/) (ignis, wofi, cava, cnf-bin, tmux, nvim, …).

## Instalación (VM)

```bash
cd ~/Games/configurations

# Config Hyprland + shared → ~/.config/
./hyprland/scripts/install-hypr.sh

# + binarios en /usr/local/bin
./hyprland/scripts/install-hypr.sh --binaries

# Tema unificado (hypr, waybar, wofi, ignis, tmux, …)
./hyprland/hyperland/scripts/apply-theme.sh blue
```

Equivalente manual:

```bash
./hyprland/hyperland/scripts/deploy-configs.sh --config-hypr
sudo ./hyprland/hyperland/scripts/install-local-binaries.sh
```

## Tras instalar

Cerrar sesión e iniciar Hyprland (p. ej. `sdm` → Hyprland).

Recarga en caliente:

```bash
hyprctl reload
```

## Documentación detallada

| Tema | README |
|------|--------|
| Hyprland modular | [`hyperland/README.md`](hyperland/README.md) |
| Waybar | [`waybar/README.md`](waybar/README.md) |
| Powerline bash | [`powerline/README.md`](powerline/README.md) |
| cnf-bin | [`../shared/cnf-bin/README.md`](../shared/cnf-bin/README.md) |
| wb_autohide | [`../waybar-auto-hide-cnf/README.md`](../waybar-auto-hide-cnf/README.md) |

## Palettes

Fuente: `hyprland/hyperland/themes/palettes.json`

```bash
./hyprland/hyperland/scripts/apply-theme.sh [theme_id]
```

## Deploy maestro

[`hyperland/scripts/deploy-configs.sh`](hyperland/scripts/deploy-configs.sh) — usado también por i3 (`--config-i3`).
