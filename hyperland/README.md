# Hyprland – Configuración modular de mi escritorio Wayland

Esta es mi configuración personal de **Hyprland**, organizada en módulos para facilitar el mantenimiento y la personalización. Incluye atajos de teclado, gestos táctiles, integración con waybar, wofi, swww, mpvpaper, y scripts útiles.

## Estructura modular

La configuración está dividida en pequeños archivos dentro de `conf.d/` que se incluyen en el orden correcto desde el archivo principal `hyprland.conf`.

~/.config/hypr/
├── hyprland.conf                 # Archivo principal con sources
├── conf.d/
│   ├── vars.conf                 # Variables globales ($mainMod)
│   ├── monitors.conf             # Monitores y variables de entorno
│   ├── exec.conf                 # Aplicaciones que se inician (exec-once, exec)
│   ├── input.conf                # Configuración de teclado, touchpad, sensibilidad
│   ├── general.conf              # Gaps, bordes, layout, colores
│   ├── decoration.conf           # Redondeo, blur, animaciones
│   ├── workspaces.conf           # Workspaces: nombres y binds para cambiar/mover
│   ├── keybinds.conf             # Todos los atajos de teclado (incluye multimedia, submapas)
│   └── gestures.conf             # Gestos táctiles (touchpad)
└── scripts/                      # Scripts auxiliares (ya existentes)
    ├── move_focus.sh    \# Script auxiliar para gestos de foco
    ├── wofi-script.sh    \# Menú de control (salir, suspender, etc.)
    ├── wofi-script1.sh    Lanzador de aplicaciones/juegos/útiles
    └── wofi_wallpaper.sh    \# Gestor de fondos de pantalla (estáticos/videos)

## 🚀 Instalación

### 1. Requisitos previos (dependencias)

Asegúrate de tener instalados los siguientes paquetes según tu distribución. Los **esenciales** son necesarios para que Hyprland funcione correctamente; los **opcionales** habilitan funciones extra.

#### Esenciales
- `hyprland` (el propio compositor)
- `waybar` (barra de estado)
- `wofi` (lanzador de aplicaciones, similar a dmenu)
- `swww` (gestor de fondos de pantalla estáticos)
- `mpvpaper` (fondos de pantalla con vídeo)
- `dunst` o `mako` (notificaciones; aquí uso `swaync`)
- `polkit-kde-agent` (para permisos)
- `brightnessctl` (control de brillo)
- `pamixer` (control de volumen)
- `libinput-gestures` (gestos táctiles)
- `setxkbmap` (distribución de teclado)
- `xdg-desktop-portal` y `xdg-desktop-portal-gtk`
- `network-manager-applet` y `blueman` (opcionales pero comunes)

#### Opcionales
- `flameshot` (capturas de pantalla)
- `copyq` (gestor del portapapeles)
- `hyprsunset` (control de temperatura de color)
- `hypridle` (gestión de inactividad)
- `hyprlock` (pantalla de bloqueo)
- `rofi` (alternativa a wofi)
- `foot` o `alacritty` (terminales)
- `brave`, `thunar`, `krita`, `libreoffice`, etc. (para los lanzadores)

#### Comandos de instalación por distribución

<details>
<summary><b>Arch Linux</b></summary>

```bash
sudo pacman -S hyprland waybar wofi swww mpvpaper dunst polkit-kde-agent \
  brightnessctl pamixer libinput-gestures xorg-setxkbmap \
  xdg-desktop-portal xdg-desktop-portal-gtk network-manager-applet blueman \
  copyq flameshot hyprsunset hypridle hyprlock foot alacritty
# Opcionales
yay -S swaync  # si prefieres swaync en lugar de dunst
```



<details> <summary><b>Fedora</b></summary>

```bash
sudo dnf install hyprland waybar wofi swww mpvplayer dunst polkit-kde \
  brightnessctl pamixer libinput-gestures xorg-x11-setxkbmap \
  xdg-desktop-portal xdg-desktop-portal-gtk NetworkManager-applet blueman \
  copyq flameshot foot alacritty
# hyprsunset, hypridle, hyprlock pueden requerir COPR o compilación
```

<details> <summary><b>openSUSE</b></summary>

```bash
sudo zypper install hyprland waybar wofi swww mpv dunst polkit-kde-agent-1 \
  brightnessctl pamixer libinput-gestures xset \
  xdg-desktop-portal xdg-desktop-portal-gtk NetworkManager-applet blueman \
  copyq flameshot foot alacritty
```

<details> <summary><b>NixOS</b></b></summary>

```bash
environment.systemPackages = with pkgs; [
  hyprland waybar wofi swww mpvpaper dunst polkit-kde-agent
  brightnessctl pamixer libinput-gestures xorg.setxkbmap
  xdg-desktop-portal xdg-desktop-portal-gtk networkmanagerapplet blueman
  copyq flameshot foot alacritty
];
```

### 2. Clonar el repositorio

bash

```bash
git clone https://github.com/tu-usuario/tu-repo.git
cd tu-repo/hyprland   # si está en una subcarpeta
```



### 3. Hacer copia de seguridad de tu configuración actual

bash

```bash
cp -r ~/.config/hypr ~/.config/hypr.bak
```



### 4. Copiar los archivos

bash

```
cp -r conf.d/ hyprland.conf hypridle.conf hyprlock.conf scripts/ ~/.config/hypr/
chmod +x ~/.config/hypr/scripts/*.sh
```



### 5. Ajustar rutas y monitores

- **Monitores**: Abre `~/.config/hypr/conf.d/monitors.conf` y cambia `eDP-1` y `HDMI-A-2` por los nombres de tus monitores (puedes verlos con `hyprctl monitors`).
- **Rutas de fondos**: En `hyprlock.conf`, la línea `path = ~/.config/i3/fondos/girlinux.png` debe apuntar a tu imagen de bloqueo. También en `wofi_wallpaper.sh` ajusta `STATIC_WALL_DIR` y `VIDEO_WALL_DIR` si usas carpetas diferentes.
- **Terminales**: Por defecto se usa `foot`. Si prefieres `alacritty`, cambia el bind `$mainMod, T` en `keybinds.conf`.

### 6. Verificar y recargar

Recarga la configuración sin reiniciar la sesión:

bash

```bash
hyprctl reload
```

Si no hay errores, los cambios se aplican. Si aparece algún error, revisa los logs con `hyprctl errors` o desde la terminal donde inicias Hyprland.



## Gestos táctiles

En `conf.d/gestures.conf`:

- **4 dedos izquierda/derecha**: cambiar workspace.
- **3 dedos izquierda/derecha/arriba/abajo**: mover el foco entre ventanas.
- **4 dedos arriba**: pantalla completa.
- **4 dedos abajo**: flotante.

## Personalización

### Temas y colores

- Los colores de bordes están en `general.conf`.
- El desenfoque y animaciones en `decoration.conf`.
- La barra de estado (waybar) se configura aparte. No está incluida en este repositorio, pero puedes usar la configuración de [mi repositorio de waybar](https://github.com/tu-usuario/waybar-config) o crear la tuya.

### Cambiar entre barras de notificaciones

En `exec.conf`, se inicia `swaync`. Si prefieres `dunst` o `mako`, cambia la línea correspondiente.

### Agregar nuevos módulos a wofi-script1.sh

El script `wofi-script1.sh` es un lanzador jerárquico. Puedes añadir nuevas opciones editando las funciones `show_apps`, `show_notes`, `show_games`, etc.

## Solución de problemas

- **Wayland no inicia**: Asegúrate de tener `libinput` y los controladores gráficos correctos. Puedes probar iniciando con `Hyprland` desde una terminal para ver errores.
- **Los gestos no funcionan**: Verifica que `libinput-gestures` esté instalado y que tu usuario esté en el grupo `input`. También asegúrate de que los gestos estén habilitados en `gestures.conf`.
- **Fondos de vídeo no se muestran**: Comprueba que `mpvpaper` esté instalado y que la ruta del vídeo sea correcta. Si usas más de un monitor, ajusta los binds en `keybinds.conf` con los nombres correctos.
- **No se ve el cursor**: Instala `xcursor-themes` y asegúrate de tener `XCURSOR_SIZE` y `XCURSOR_THEME` definidos (ya están en `monitors.conf`).

## Notas finales

- Esta configuración está pensada para ser usada tal cual, pero es fácilmente modificable gracias a su estructura modular.
- Algunos scripts dependen de programas externos (mame, gzdoom, etc.) que no están incluidos. Si no los usas, comenta o elimina las opciones correspondientes.
- Si encuentras errores o quieres sugerir mejoras, ¡no dudes en abrir un issue!
