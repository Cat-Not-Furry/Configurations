# dwm-full

Fork de [DWM de Ferchupessoadev](https://github.com/Ferchupessoadev/dwm) con barra personalizada e integración **cnf-bin**.

## Instalación

```bash
# Compilar dwm + st
./dwm-full/install.sh

# Binarios cnf-info / cnf-media (barra)
./shared/install.sh --binaries
# o
./shared/cnf-bin/build-install.sh
```

Tras compilar, configura `~/.xinitrc` para ejecutar `dwm` y copia/enlaza `st`.

## Integración cnf-bin

| Binario | Uso en barra |
|---------|--------------|
| `cnf-info` | Batería, temperatura, CPU, brillo |
| `cnf-media` | Media MPRIS (Zen, Firefox, Brave…) |

Plantilla: [`bar/scripts/cnf-bar.sh`](bar/scripts/cnf-bar.sh)

```bash
chmod +x bar/scripts/cnf-bar.sh
# Invocar desde bar.sh del fork
```

Config MPRIS: `shared/cnf-bin/config.toml` → sección `[media]`.

## Atajos

Cambio de escritorio: **MOD/SUPER + Alt + ←/→**

## Estructura

```
dwm-full/
├── install.sh
├── README.md
├── bar/scripts/       # cnf-bar.sh
├── dwm/               # Makefile, config.h, patches/
└── st/                # terminal st
```

### dwm/

```
dwm/
├── bar/               # scripts de la barra
├── codules/           # fuentes .c
├── hodules/           # cabeceras .h
├── core/              # autostart
├── docs/
├── patches/
├── config.h
├── config.mk
└── Makefile
```

### st/

```
st/
├── codules/
├── hodules/
├── config.h
├── config.mk
└── Makefile
```

## Requisitos

```bash
sudo pacman -S base-devel libx11 libxft libxinerama
# Para cnf-bar: cnf-info, cnf-media en PATH
```

## Notas

- No hay display manager integrado; usar `startx` o `sdm` desde consola.
- Probar compilación en VM antes de usar en hardware principal.
- [DWM original del fork](https://github.com/Ferchupessoadev/dwm)
