# btop

Configuración personal de [btop](https://github.com/aristocratos/btop) (monitor de CPU, memoria, disco, red).

## Contenido

```
btop/
├── btop.conf      # Config principal (tema tokyo-night)
├── install.sh     # Copia a ~/.config/btop/
└── README.md
```

## Instalación

```bash
sudo pacman -S btop
./btop/install.sh
```

Equivale a:

```bash
mkdir -p ~/.config/btop
install -m644 btop/btop.conf ~/.config/btop/btop.conf
```

## Uso

```bash
btop
# o como fondo en terminal: bgterm btop  (requiere cnf-bin en PATH)
```

## Tema

`btop.conf` referencia `theme = "tokyo-night"`. Instala el tema del sistema si no está:

```bash
# Ejemplo Arch: paquete btop incluye temas en /usr/share/btop/themes/
ls /usr/share/btop/themes/
```

## Notas

- No forma parte del deploy automático de i3/Hyprland; instalación manual con `install.sh`.
- Probar en VM antes de usar en producción.
