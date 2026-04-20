# Waybar – Configuración para Hyprland

Esta carpeta contiene mi configuración personal de **Waybar**, una barra de estado para entornos Wayland. Está optimizada para Hyprland, con módulos para workspaces, música (cmus), visualizador de audio (cava), CPU, temperatura, memoria, disco, volumen, brillo, batería, hostname, fecha y bandeja de sistema.

## Estructura

~/.config/waybar/<br>
├── config # Configuración principal (JSON)<br>
├── style.css # Estilos visuales<br>
└── scripts/ # Scripts auxiliares<br>
├── cmus_status.sh # Estado de cmus (ícono + artista/título)<br>
├── kblight.sh # Retroiluminación del teclado (ThinkPad)<br>
├── temp_status.sh # Temperatura del sistema (máxima)<br>
└── waybar_date_icon.sh # Fecha y hora con ícono dinámico<br>

## Instalación

### 1. Dependencias

| Paquete           | Función                              |
| ----------------- | ------------------------------------ |
| `waybar`          | La barra en sí                       |
| `cmus`            | Reproductor de música (opcional)     |
| `cava`            | Visualizador de audio (opcional)     |
| `brightnessctl`   | Control de brillo y retroiluminación |
| `pamixer`         | Control de volumen                   |
| `acpi` o `upower` | Estado de batería                    |
| `lm_sensors`      | Temperatura del sistema              |
| `ttf-hack-nerd`   | Fuente con íconos                    |

**Comandos de instalación por distribución**:

<b>Arch Linux</b>


```bash
sudo pacman -S waybar cmus cava brightnessctl pamixer acpi lm_sensors ttf-hack-nerd
```

<b>Debian / Ubuntu</b>

```bash
sudo apt update
sudo apt install waybar cmus cava brightnessctl pamixer acpi lm-sensors fonts-hack-ttf
```

<b>Fedora</b>

```bash
sudo dnf install waybar cmus cava brightnessctl pamixer acpi lm_sensors hack-fonts
```

<b>openSUSE</b>

```bash
sudo zypper install waybar cmus cava brightnessctl pamixer acpi lm_sensors hack-fonts
```



### 2. Copiar la configuración

```bash
# Haz una copia de seguridad (si existe)
mv ~/.config/waybar ~/.config/waybar.bak

# Clona el repositorio y copia los archivos
git clone https://github.com/tu-usuario/tu-repo.git
cp -r tu-repo/waybar ~/.config/
```



### 3. Dar permisos de ejecución a los scripts

```bash
chmod +x ~/.config/waybar/scripts/*.sh
```



### 4. Ajustar rutas y opciones específicas

- **Teclado retroiluminado**: En `scripts/kblight.sh`, cambia `DEVICE="tpacpi::kbd_backlight"` por el nombre de tu dispositivo (p.ej. `asus::kbd_backlight`). Si tu teclado no tiene retroiluminación, elimina el módulo `custom/kblight` del `config`.

- **Batería**: Verifica el nombre de tu batería en `config` (por defecto `BAT0`). Ejecuta `ls /sys/class/power_supply/` para verlo.

- **Temperatura**: El script `temp_status.sh` recorre todas las zonas térmicas. Asegúrate de tener cargado el módulo `thermal` del kernel.

  

### 5. Iniciar Waybar

Para iniciar Waybar manualmente:

```cobol
waybar
```



Para que se inicie automáticamente con Hyprland, añade la siguiente línea a `~/.config/hypr/conf.d/exec.conf`:



```cobol
exec = waybar &
```



## Módulos y scripts

### Módulos de la izquierda

- `hyprland/workspaces` – Espacios de trabajo con íconos (activo, inactivo, urgente). Scroll para cambiar.
- `hyprland/window` – Título de la ventana activa.

### Módulos centrales

- `custom/cmus` – Control de cmus. Muestra artista y canción actual.
  Clicks: izquierdo → anterior, central → pausa/reanuda, derecho → siguiente.
- `custom/cava` (opcional) – Visualizador de audio en tiempo real. Solo se muestra cuando hay reproducción.

### Módulos de la derecha

- `cpu` – Uso de CPU (porcentaje). Click → abre `htop`.
- `custom/temp` – Temperatura máxima del sistema. Ícono y color según rango.
- `memory` – Uso de RAM en GB.
- `disk` – Espacio usado en `/`.
- `pulseaudio` – Volumen. Click → abre `pavucontrol`.
- `custom/kblight` – Nivel de retroiluminación del teclado (50% / 100%).
- `backlight` – Brillo de la pantalla.
- `battery` – Estado de la batería (icono, porcentaje, tiempo restante).
- `custom/hostname` – Nombre del equipo.
- `custom/date` – Fecha y hora con ícono que cambia según la hora (fases de la luna).
- `tray` – Bandeja de sistema (applets de red, Bluetooth, etc.).

## Personalización

### Colores y estilo

Edita `style.css` para cambiar colores, bordes, redondeo, fuentes, etc. Las variables principales están en la sección `window#waybar`.

### Modificar íconos

Los íconos usan **Nerd Fonts**. Puedes cambiarlos en `config` (por ejemplo, en `format-icons` o en los `format`). Consulta [Nerd Fonts Cheat Sheet](https://www.nerdfonts.com/cheat-sheet) para buscar códigos.

### Añadir o quitar módulos

Edita las listas `modules-left`, `modules-center` y `modules-right` en `config`. Los nombres deben coincidir con las secciones definidas.

### Personalizar scripts

Todos los scripts están en `scripts/`. Puedes modificarlos para cambiar la información mostrada o los comandos ejecutados al hacer clic.

## Solución de problemas

- **Waybar no se inicia**: Ejecútalo desde una terminal para ver errores. Verifica que tienes todas las dependencias.
- **Módulos vacíos**: Prueba los scripts manualmente (`./scripts/cmus_status.sh`). Si fallan, revisa que los programas asociados estén instalados.
- **Íconos no se ven**: Instala `ttf-hack-nerd` y verifica que la fuente esté configurada en `style.css`. Si usas otra fuente, ajusta `font-family`.
- **Visualizador no funciona**: Asegúrate de que `cava` está instalado y que `pulseaudio` (o `pipewire-pulse`) está ejecutándose. Prueba `cava` en terminal para verificar.
- **Retroiluminación no funciona**: Ejecuta `ls /sys/class/leds/` para encontrar el nombre correcto de tu dispositivo. Cambia `DEVICE` en `kblight.sh`.

## Notas finales

- La configuración está pensada para **Hyprland** (usa `hyprland/workspaces` y `hyprland/window`). Si usas otro compositor (como Sway), cambia los módulos a `sway/workspaces` y `sway/window`.
- El visualizador `cava` puede consumir recursos; si notas lentitud, aumenta el intervalo en el script o elimina el módulo.
- Para el calendario al hacer clic en la fecha, se abre `cal -y` en una terminal (`alacritty`). Si usas otra terminal, cambia `alacritty` por tu emulador.