# dwmbar - Dynamic Window Manager bar (configuración personal)

## Requisitos (para dwmbar)

- `brightnessctl`, `acpi`, `lm-sensors`, `bc`, `pulseaudio`/`pipewire-pulse`

### Instalación de dependencias en distribuciones comunes

### Debian

```bash
sudo apt install build-essential git libx11-dev libxft-dev libxinerama-dev pkg-config brightnessctl lm-sensors bc
```



### Arch Linux

```bash
sudo pacman -S base-devel git libx11 libxft libxinerama pkg-config brightnessctl acpi lm_sensors bc
```



### Fedora

```bash
sudo dnf install @development-tools git libX11-devel libXft-devel libXinerama-devel pkgconfig brightnessctl lm_sensors bc
```



```bash
git clone https://github.com/tu-usuario/dwm.git
cd dwm
sudo make clean install
```



## Instalación:

Solo tiene que copiar la carpeta  `bar` a `.config`

```bash
cp -r bar ~/.config/dwmbar
```

### Scripts disponibles

| Script         | Descripción                                |
| :------------- | :----------------------------------------- |
| `clock.sh`     | Fecha y hora con iconos Nerd Fonts         |
| `cpu.sh`       | Frecuencia actual de la CPU                |
| `memoria.sh`   | Uso de RAM (libre/total)                   |
| `disk_root.sh` | Espacio usado en la raíz                   |
| `bateria.sh`   | Estado de la batería (solo si existe BAT0) |
| `brillo.sh`    | Brillo actual (requiere brightnessctl)     |
| `temp.sh`      | Temperatura de la CPU (sensors)            |
| `volume.sh`    | Volumen y mute de PulseAudio               |
| `host.sh`      | Nombre del equipo                          |
| `wifi_ip.sh`   | IP local (opcional)                        |

### Requisitos de los scripts

- **Iconos:** necesitas una fuente que incluya Nerd Fonts (por ejemplo, `Hack Nerd Font` está configurada en `config.h`).
- **Herramientas externas:** `brightnessctl`, `acpi`, `lm-sensors`, `bc`, `pactl` (viene con PulseAudio/PipeWire).

## Ejemplo de edición:

Puedes editar la dwmbar es sencillo, solo tienes que escribir el orden en el que los scripts de la barra de visualizaran

```bash
xdg-editor bar.sh
```



```bash
#!/bin/bash

DIR="$HOME/.config/dwmbar/scripts" # Busca la los scripts
while [[ true ]]; do # Carga los scripts y los ejecuta
  fecha_hora="$($DIR/clock.sh)"
  mem="$($DIR/memoria.sh)"
  #wifi_ip=$($DIR/wifi_ip.sh)
  disk_root=$($DIR/disk_root.sh)
  vol=$($DIR/volume.sh)
  #ip_public="󰩟 :$(curl ifconfig.me)"
  #disk_home=$($DIR/disk_home.sh)
  #batt=$($DIR/batt.sh)
  temp=$($DIR/temp.sh)
  host=$($DIR/host.sh)
  cpu=$($DIR/cpu.sh)
  bate=$($DIR/bateria.sh)
  bllo=$($DIR/brillo.sh)
  xsetroot -name "$cpu $temp $mem $disk_root $bate $bllo $host $fecha_hora" # Muestra la salida de los que deseas ver
  sleep 1
done
```



> [!NOTE]
>
> Cada que termines de personalizar la barra no olvides recargar con:

```bash
pkill -f bar.sh
~/.config/dwmbar/bar.sh &
```



### O añade en hodules/keys.h

```c++
{ MODKEY | ShiftMask, XK_r, spawn, SHCMD("pkill -f bar.sh; ~/.config/dwmbar/bar.sh &") },
```

### Y recompila el proyecto