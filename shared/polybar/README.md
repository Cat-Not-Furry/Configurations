# Polybar – Configuración personalizada

Esta carpeta contiene mi configuración de **Polybar**, una barra de estado altamente personalizable. Incluye módulos para i3, música (cmus), CPU, temperatura, memoria, disco, batería, volumen, brillo, retroiluminación del teclado, fecha y más.

## 📁 Estructura

~/.config/polybar/
├── config.ini # Archivo de configuración principal
├── launch.sh # Script para lanzar Polybar (con killall previo)
└── scripts/ # Scripts utilizados por los módulos
	├── cmus_status.sh # Estado de cmus (ícono y canción actual)
	├── cpu_status.sh # Frecuencia de la CPU con colores
	├── kbdlight.sh # Nivel de retroiluminación del teclado (ThinkPad)
	├── keyboard.sh # Estado del teclado (ON/OFF) – usado por el módulo keyboard
	├── keyboard_status.sh # (Alternativa) Script similar, actualmente no utilizado
	├── polybar_date_icon.sh # Fecha y hora con ícono dinámico por hora
	├── temp_status.sh # Temperatura del sistema (máxima entre zonas)
	└── toggle_calendar.sh # Alterna un calendario con eww (opcional)

## 🚀 Instalación

### 1. Dependencias

Asegúrate de tener instalados los siguientes paquetes:

| Paquete           | Función                                |
| ----------------- | -------------------------------------- |
| `polybar`         | La barra en sí                         |
| `cmus`            | Reproductor de música (opcional)       |
| `lm_sensors`      | Para temperatura (si se usa `sensors`) |
| `brightnessctl`   | Control de brillo de pantalla          |
| `pamixer`         | Control de volumen (alternativa)       |
| `acpi` o `upower` | Estado de batería                      |
| `eww`             | Para el calendario (opcional)          |
| `xorg-xinput`     | Para el estado del teclado             |
| `ttf-hack-nerd`   | Fuente con íconos                      |
| `font-awesome`    | Íconos adicionales                     |

**En Arch Linux**:
```bash
sudo pacman -S polybar cmus lm_sensors brightnessctl pamixer acpi eww xorg-xinput ttf-hack-nerd font-awesome
```



**En Debian/Ubuntu**:

bash

```bash
sudo apt install polybar cmus lm-sensors brightnessctl pamixer acpi eww xinput fonts-hack-ttf fonts-font-awesome
```

**Fedora**

```bash
sudo dnf install polybar cmus lm_sensors brightnessctl pamixer acpi \
  xorg-x11-xinput hack-fonts fontawesome-fonts
# Opcionales: eww requiere copiar o compilación
```

**openSUSE**

```bash
sudo zypper install polybar cmus lm_sensors brightnessctl pamixer acpi \
  xinput hack-fonts fontawesome-fonts
```

**Void Linux**

```bash
sudo xbps-install -S polybar cmus lm_sensors brightnessctl pamixer acpi \
  xinput hack-fonts font-awesome
```



**Gentoo**

```bash
emerge --sync
emerge -av polybar cmus lm_sensors brightnessctl pamixer acpi \
  x11-apps/xinput media-fonts/hack media-fonts/fontawesome
```



**NixOS**

En `configuration.nix`:

```bash
environment.systemPackages = with pkgs; [
  polybar
  cmus
  lm_sensors
  brightnessctl
  pamixer
  acpi
  xorg.xinput
  hack-font
  font-awesome
];
# Opcional: eww
  eww
```



Luego ejecuta `sudo nixos-rebuild switch`.

**Alpine Linux**

```bash
apk add polybar cmus lm_sensors brightnessctl pamixer acpi \
  xinput hack-font font-awesome
```



### 2. Copiar la configuración

```bash
# Haz una copia de seguridad de tu configuración actual (si existe)
mv ~/.config/polybar ~/.config/polybar.bak

# Clona el repositorio (o copia esta carpeta a ~/.config/polybar)
git clone https://github.com/tu-usuario/tu-repo.git
cp -r tu-repo/polybar ~/.config/
```



### 3. Dar permisos de ejecución a los scripts

```bash
chmod +x ~/.config/polybar/scripts/*.sh
```



### 4. Ajustar rutas y opciones específicas

- **Teclado retroiluminado**: Si tu portátil no es ThinkPad, edita `scripts/kbdlight.sh` y cambia la variable `LED_PATH` por la ruta correcta de tu dispositivo.
- **Batería**: Verifica que el nombre de la batería en `config.ini` (por defecto `BAT0`) coincida con el tuyo. Ejecuta `ls /sys/class/power_supply/` para verlo.
- **Monitor de temperatura**: El script `temp_status.sh` busca todas las zonas térmicas y muestra la más alta. Si no encuentras ninguna, asegúrate de tener cargado el módulo `thermal` del kernel.
- **Calendario**: El script `toggle_calendar.sh` requiere eww configurado; si no lo usas, comenta o elimina el módulo `date` o su click.

### 5. Iniciar Polybar

Puedes lanzar la barra manualmente con:

bash

```bash
~/.config/polybar/launch.sh
```



Para que se inicie automáticamente con i3/Hyprland, añade la línea correspondiente a tu archivo de configuración:

**i3** (`~/.config/i3/config` o en `exec.conf`):

conf

```bash
exec_always --no-startup-id ~/.config/polybar/launch.sh
```



**Hyprland** (`~/.config/hypr/conf.d/exec.conf`):

conf

```bash
exec = ~/.config/polybar/launch.sh
```



## Módulos y scripts destacados

### Módulo `keyboard`

### Módulo `cmus`

- Muestra el estado actual (▶️ / ⏸️ / ⏹️) junto con el artista y título de la canción.
- Los clicks en el módulo controlan la reproducción:
  - **Click izquierdo**: canción anterior
  - **Click central**: pausa/reanuda
  - **Click derecho**: siguiente canción

### Módulo `cpu-status`

- Muestra la frecuencia del primer núcleo de CPU en GHz, coloreada según su valor:
  - **Verde**: < 2.0 GHz
  - **Amarillo**: entre 2.0 y 3.5 GHz
  - **Rojo**: > 3.5 GHz
- Al hacer clic, abre `htop` en una terminal.

### Módulo `temp-status`

- Muestra la temperatura más alta de todas las zonas térmicas.
- Ícono y color cambian según la temperatura:
  - 🧊 (< 35°C), 🌡️ (35-45°C), 🔥 (45-60°C), ⚠️ (> 60°C).

### Módulo `kbdlight`

- Muestra el nivel de retroiluminación del teclado (solo para ThinkPad por defecto).
- Niveles: apagado, 50% o 100%.

### Módulo `date`

- Muestra fecha y hora con un ícono que cambia cada hora (representa la posición del sol).
- Al hacer clic, abre un calendario anual en la terminal.

## Personalización

### Modificar colores

Los colores están definidos al inicio de `config.ini` en la sección `[colors]`. Cambia los valores hexadecimales a tu gusto.

### Cambiar fuente de íconos

Por defecto se usan fuentes **Hack Nerd Font** y **Font Awesome**. Si quieres otros íconos, ajusta las líneas `font-*` y reemplaza los códigos Unicode en los módulos (por ejemplo, `` por otro).

### Añadir o quitar módulos

Edita las listas `modules-left`, `modules-center` y `modules-right` en la sección `[bar/mybar]`. Los nombres deben coincidir con los definidos en `[module/*]`.

### Personalizar scripts

Todos los scripts están en `scripts/`. Puedes modificarlos para adaptar la información mostrada, los colores o los comandos ejecutados al hacer clic.

## Solución de problemas

- **La barra no aparece**:
  - Asegúrate de que `polybar` está instalado.
  - Ejecuta `~/.config/polybar/launch.sh` en una terminal y observa si hay errores.
  - Comprueba que los scripts tienen permisos de ejecución.
- **Módulos vacíos o errores**:
  - Cada script se ejecuta independientemente; prueba ejecutarlos manualmente para ver su salida.
  - Si un módulo no muestra nada, revisa si las dependencias están instaladas (ej. `cmus-remote` para cmus).
- **Teclado retroiluminado no funciona**:
  - Verifica la ruta en `kbdlight.sh` con `ls /sys/class/leds/`.
  - Si tu teclado no tiene retroiluminación, comenta o elimina ese módulo de `modules-right`.
- **Click en módulos no responde**:
  - Revisa que los comandos asociados existan (ej. `pavucontrol`, `htop`, `alacritty`).
  - En i3/Hyprland, los comandos se ejecutan en el entorno de la sesión; asegúrate de que los ejecutables están en el PATH.

## Notas finales

- Esta configuración está pensada para ser usada con **i3** o **Hyprland**, pero puede adaptarse a otros gestores de ventanas.
- Los íconos dependen de **Nerd Fonts**; si no los ves, instala una fuente compatible (ej. `ttf-hack-nerd`).
- Para el calendario con eww, necesitarás una configuración de eww aparte; si no la tienes, puedes comentar la línea `click-left` en el módulo `date` para evitar errores.