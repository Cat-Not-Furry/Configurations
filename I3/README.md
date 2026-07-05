# Stack i3 (X11)

Configuración **i3** + **bumblebee-status** + componentes compartidos en [`../shared/`](../shared/).

## Estructura

```
I3/
├── i3-wm/              → ~/.config/i3/
├── bumblebee-status/   → ~/.config/bumblebee-status/
└── scripts/
    ├── install-i3.sh   ← instalar (recomendado)
    └── deploy-i3.sh    ← wrapper fino a deploy-configs.sh
```

## Instalación (VM)

```bash
cd ~/.cache/Configurations

# Config completa i3 + shared → ~/.config/
./I3/scripts/install-i3.sh

# + binarios cnf-info, thinkfan, etc. en /usr/local/bin
./I3/scripts/install-i3.sh --binaries

# Opcional: wallpapers del repo → ~/.config/fondos/
./I3/scripts/install-i3.sh --fondos
./I3/scripts/install-i3.sh --fondos-all   # incluye other/
```

Equivalente manual:

```bash
./hyprland/hyperland/scripts/deploy-configs.sh --config-i3
./hyprland/hyperland/scripts/deploy-configs.sh --config-i3 --fondos-all   # + fondos
sudo ./hyprland/hyperland/scripts/install-local-binaries.sh
```

## Tras instalar

```bash
# Tema (i3, bumblebee/polybar, nvim/tokyonight vía palettes.json)
~/.config/i3/scripts/apply-i3-theme.sh classic   # o iceberg

# Fondos (X11): comando fondo → ~/.config/fondos/
fondo f

# Recargar i3 si ya está activo
i3-msg reload

# Iniciar sesión (ejemplo)
startx ~/.xinitrc    # o sdm → i3
```

## Documentación detallada

- [`i3-wm/README.md`](i3-wm/README.md) — conf.d, scripts, dependencias
- [`bumblebee-status/README.md`](bumblebee-status/README.md) — barra i3bar
- [`../shared/cnf-bin/README.md`](../shared/cnf-bin/README.md) — cnf-info, cnf-media, thinkfan
- [`../shared/fondos/README.md`](../shared/fondos/README.md) — wallpapers (`~/.config/fondos/`)

## Binarios Rust

```bash
./shared/cnf-bin/build-install.sh
```

## Notas

- Blueman, nm-applet, copyq: `ensure-tray-services.sh` + reglas en `conf.d/`
- Polybar opcional: `conf.d/06-pbar.conf` (no incluido en config principal por defecto)
