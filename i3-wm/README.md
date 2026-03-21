# **i3-wm**

## La configuración de mi escritorio
*** Grita * La procrastinación esta matándome, debería estar estudiando para calculo integral... pero prefiero explicar las dependencias de mi config**

>[!WARNING]
>Cabe resaltar que no soy ningún experto y que, por consiguiente es **tu** responsabilidad la descarga y reemplazo de este archivo.
**Aun así, si deseas probar la configuración que tengo puedes hacer lo siguiente...**

**Si gustas puedes pasarte por el [sitio oficial](https://i3wm.org/docs/userguide.html) a ver la guía de usuario**

## Dependencias necesarias

Para que toda la configuración funcione correctamente, necesitas instalar los siguientes paquetes. La lista está dividida en **esenciales** (sin ellos el escritorio no funcionará bien) y **opcionales** (para funciones específicas que quizás no uses).

### Esenciales
- **i3-gaps** (versión con gaps, no el i3 estándar)
- **alacritty** (terminal por defecto)
- **rofi** (lanzador de aplicaciones)
- **dunst** (sistema de notificaciones)
- **polkit-kde-agent** (para gestionar permisos de aplicaciones)
- **xdg-desktop-portal** y **xdg-desktop-portal-gtk** (para integración con Flatpak/sandbox)
- **feh** o **nitrogen** (para fondos de pantalla; aunque en mi configuración está comentado, puedes necesitarlo)
- **font** `ttf-hack-nerd` o similar (para la fuente)
- **brightnessctl** (control de brillo)
- **pulseaudio** y **pactl** (para audio)
- **xss-lock** (para bloquear la pantalla al suspender)
- **nm-applet** (applet de NetworkManager) y **blueman-applet** (para Bluetooth)
- **libinput-gestures** (gestos táctiles)
- **setxkbmap** (para cambiar distribución del teclado)

### Opcionales (para funciones extra)
- **flameshot** (capturas de pantalla)
- **polybar** o [**bumblebee-status**](https://www.youtube.com/watch?v=jZTCKoJwLFo) (barra de estado; dependiendo de qué archivo uses, dejare las carpetas con los modulos que uso)
- **eww** (widgets, usado con `$mod+Shift+n`)
- **cmus** (reproductor de música, si usas el módulo en bumblebee-status)
- **lm_sensors** (para monitoreo de temperatura)
- **pipewire** (si usas audio moderno)
- **dmenu** y **i3-dmenu-desktop** (lanzadores alternativos)
- **brightnessctl** (ya incluido)
- **unclutter** o similar (si necesitas ocultar el cursor, no aparece en la configuración pero es común)

### Debian

```bash
sudo apt update
sudo apt install i3-gaps alacritty rofi dunst policykit-1-gnome \
  xdg-desktop-portal xdg-desktop-portal-gtk feh fonts-hack-ttf \
  brightnessctl pulseaudio-utils xss-lock network-manager-gnome \
  blueman libinput-tools x11-xkb-utils
# Opcionales
sudo apt install flameshot polybar cmus lm-sensors dmenu
```



### Arch Linux

```bash
sudo pacman -S i3-gaps alacritty rofi dunst polkit-kde-agent \
  xdg-desktop-portal xdg-desktop-portal-gtk feh ttf-hack-nerd \
  brightnessctl pulseaudio-utils xss-lock network-manager-applet \
  blueman libinput-gestures xorg-setxkbmap
# Opcionales (oficiales)
sudo pacman -S flameshot polybar cmus lm_sensors dmenu
# Desde AUR (con yay)
yay -S bumblebee-status eww-git
```



### Fedora

```bash
sudo dnf install i3-gaps alacritty rofi dunst polkit-kde \
  xdg-desktop-portal xdg-desktop-portal-gtk feh hack-fonts \
  brightnessctl pulseaudio-utils xss-lock NetworkManager-applet \
  blueman libinput-gestures xorg-x11-setxkbmap
# Opcionales
sudo dnf install flameshot polybar cmus lm_sensors dmenu
```



### openSUSE

```bash
sudo zypper install i3-gaps alacritty rofi dunst polkit-kde-agent-1 \
  xdg-desktop-portal xdg-desktop-portal-gtk feh hack-fonts \
  brightnessctl pulseaudio-utils xss-lock NetworkManager-applet \
  blueman libinput-gestures xset
# Opcionales
sudo zypper install flameshot polybar cmus lm_sensors dmen
```



### Alpine Linux

```bash
apk add i3wm i3status xterm
apk add xf86-video-fbdev xf86-video-vesa font-terminus
apk add alacritty rofi dunst feh brightnessctl pulseaudio-utils
```

> [!NOTE]
>
> i3-gaps no está disponible en repositorios oficiales de Alpine



### Void Linux

```bash
xbps-install -S
xbps-install i3-gaps i3status i3blocks
xbps-install alacritty rofi dunst feh brightnessctl pulseaudio-utils
xbps-install NetworkManager network-manager-applet blueman
xbps-install xf86-input-libinput
xbps-install font-firacode font-adobe-source-code-pro font-awesome6
# Habilitar servicios
ln -s /etc/sv/dbus /var/service
ln -s /etc/sv/NetworkManager /var/service
```



### Gentoo

```bash
emerge --sync
emerge -av i3-gaps
emerge -av alacritty rofi dunst feh brightnessctl pulseaudio
```

> [!NOTE]
>
> Para i3-gaps, habilitar USE flag "gaps" en /etc/portage/package.use:<br>x11-wm/i3-gaps -gaps



### FreeBSD

```bash
pkg update
pkg install i3-gaps
pkg install alacritty rofi dunst feh brightnessctl
```

> [!NOTE]
>
> Nota: i3-gaps en FreeBSD está deprecado, se recomienda migrar a x11-wm/i3



### Slackware

```bash
# i3-gaps disponible via SlackBuilds.org
# 1. Descargar SlackBuild:
wget https://slackbuilds.org/slackbuilds/15.0/desktop/i3-gaps.tar.gz
tar xzf i3-gaps.tar.gz
cd i3-gaps
# 2. Descargar código fuente y construir:
./i3-gaps.SlackBuild
# 3. Instalar paquete generado:
installpkg /tmp/i3-gaps-*.txz
```



### NixOS

```bash
# En configuration.nix agregar:
environment.systemPackages = with pkgs; [
  i3-gaps
  alacritty
  rofi
  dunst
  feh
  brightnessctl
  pulseaudio
];
# Luego:
sudo nixos-rebuild switch
```



### Scripts personalizados
Algunos atajos dependen de scripts que debes tener en las rutas indicadas:
- `~/.config/i3/scripts/lock.sh` – bloqueo de pantalla (usado con `xss-lock`)
- `~/.config/i3/scripts/dmenu-script.sh` y `dmenu-script1.sh` – lanzadores personalizados
- `~/.local/bin/toggle-keyboard.sh` – cambiar distribución del teclado
- `~/.config/eww/launch.sh` – lanzador de eww
- `life_fondo` y `dead_fondo.sh` – scripts para fondos animados (puedes reemplazarlos o eliminarlos)
- `touchpad` – script para configurar el touchpad (probablemente un alias o script personal)

Si no usas estas funciones, comenta o borra las líneas correspondientes en el archivo de configuración.

### Notas adicionales
- El archivo `config` utiliza **bumblebee-status** como barra; `config.hypr` usa **polybar**. Asegúrate de tener el que corresponda y quieres statusbar comenta las lineas que hacen referencia a estas barras y descomenta la bar `lineas 213 ~ 232`

- Si usas `config.hypr`, ten en cuenta que está pensado para funcionar junto a **polybar** (necesitarías renombrar el archivo en `.config` o en la ubicación). 

  ```bash
  mv ~/.config/i3/config.hypr mv ~/.config/i3/config
  ```

  

  > [!NOTE]
  >
  > Revisa los ejecutables y rutas.

- Para que los atajos de volumen y brillo funcionen, verifica que los comandos `pactl` y `brightnessctl` estén instalados y que los nombres de los sinks/dispositivos sean correctos.

## Cómo fusionar la configuración (para evitar errores)

### En lugar de reemplazar completamente tu archivo `~/.config/i3/config`, lo mejor es **fusionar** las partes personalizadas. Sigue estos pasos:

### Instrucciones:

1. Copie la configuración de su entorno en u archivo bak

   ```bash
   cp ~/.config/i3/config ~/.config/i3/config.bak
   ```

   Y para recuperarlo:

   ```bash
   cp ~/.config/i3/config.bak ~/.config/i3/config
   ```

   > [!NOTE]
   >
   > Ya probe reemplazar el archivo por el de la instalación y me da errores, por lo mismo lo más recomendable es que copies y pegues las partes que te interesen para que evites conflictos de compatibilidad.

2. **Abre tu archivo actual** y el archivo del repo (`config` o `config.hypr`) con un editor de texto. (Si utiliza config.hypr tiene que quitar el .hypr)

3. **Identifica el punto de inserción**: Por lo general, el archivo generado por i3 tiene una estructura fija. Puedes empezar a copiar después de la línea que define `$mod` (normalmente `set $mod Mod4`). Si quieres conservar la sección de fuentes, comienza después del bloque `font pango: ...`.

4. **Copia y pega** las partes que te interesen:

   - **Workspaces con nombres** (las líneas que comienzan con `set $ws1 ...` y los binds correspondientes).
   - **Bindsyms personalizados** (como `bindsym $mod+Shift+t exec ...`).
   - **La barra** (bloque `bar { ... }`) si usas una diferente.
   - **Opciones de gaps y bordes** (líneas como `gaps outer 2`, `smart_gaps on`, `for_window ...`).
   - **Ejecuciones automáticas** (`exec_always` o `exec`) que no tengas ya.

   Asegúrate de **no duplicar** binds que ya existan en tu archivo original (por ejemplo, si ya tienes `bindsym $mod+Return exec terminal`, no agregues otro). Si un atajo está definido dos veces, i3 usará el primero, pero puede causar confusión.

5. **Revisa conflictos**: Algunos programas que inicias automáticamente (como `nm-applet`, `blueman-applet`) pueden estar ya en tu archivo. Si ya están, omítelos para evitar duplicados.

6. **Prueba la configuración** sin reiniciar i3:

   ```bash
   i3-msg reload
   ```

   Si no hay errores, el cambio se aplica. Si aparece algún error, revisa las líneas que pegaste.

7. Si todo funciona, reinicia i3 con $mod+Shift+r para asegurarte de que todo arranca correctamente.

### Ejemplo de fusión

Suponiendo que tu archivo generado actualmente termina después de la definición de `mode "resize"` y la barra básica, podrías añadir después de `bindsym $mod+r mode "resize"` todo lo que viene en mi configuración desde la línea `# Miselaneus` en adelante, pero revisando que no haya duplicados.

Si prefieres un enfoque más automático, puedes usar `sed` para insertar después de una línea específica, pero es más fácil hacerlo manualmente la primera vez.

> [!NOTE]
>
> Recuerda: **tú eres responsable de los cambios**, así que ten siempre una copia de seguridad funcional.

## Atajos que agregue

Si gustas puedes pasarte por el [sitio oficial](https://i3wm.org/docs/userguide.html) a ver la guia de usuario
