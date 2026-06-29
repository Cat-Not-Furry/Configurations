# **i3-wm**

> Barra vía [`../bumblebee-status/`](../bumblebee-status/) y `cnf-info` / `cnf-media`.

## La configuración de mi escritorio

```
i3-wm/
├── config                         # Archivo principal con includes
├── conf.d/
│   ├── 00-env.conf                # scripts/i3-environment.sh (env X11, portales)
│   ├── 00-exec.conf               # ensure-tray-services.sh, xss-lock, etc.
│   ├── 01-binds_media.conf        # Atajos de volumen, brillo, bloqueo
│   ├── 02-binds_focus_move.conf   # Terminal, lanzadores, foco, mover, layout
│   ├── 03-workspaces.conf         # Workspaces y atajos
│   ├── 04-binds_misc.conf         # Recargar, reiniciar, salir, resize
│   ├── 05-bbar.conf               # i3bar + bandeja (bumblebee-status)
│   ├── 06-pbar.conf               # Polybar (opcional; no incluido en config)
│   ├── 07-gaps_borders.conf       # gaps + bordes (copia de themes/{classic|iceberg}.conf)
│   ├── conf.d/themes/             # classic.conf, iceberg.conf, bumblebee-bar-*
│   └── 08-scripts.conf            # capturas maim, eww, copyq, fondos
└── scripts/
    ├── i3-environment.sh          # Env X11, limpia Wayland, dunst/portales
    ├── ensure-tray-services.sh    # nm-applet, blueman, copyq (tras i3bar)
    ├── x11-screenshot-region.sh   # Print — región → portapapeles
    ├── apply-i3-theme.sh          # classic | iceberg (lee config.toml [i3])
    ├── toggle-status-bar.sh       # bumblebee ↔ polybar (prueba)
    ├── kbdlight.sh                # luz teclado (fallback polybar / legacy)
    ├── lock.sh
    ├── dmenu-script.sh
    └── dmenu-script1.sh
```

> Los archivos de este README **solo viven en el repo** (`i3-wm/`). `deploy-configs.sh` los copia a `~/.config/i3/` en el sistema; la documentación no se despliega.

**(Grita) La procrastinación esta matándome, debería estar programando un proyecto muy importante... pero prefiero explicar las dependencias de mi config**

>[!WARNING]
>Cabe resaltar que no soy ningún experto y que, por consiguiente es **tu** responsabilidad la descarga y reemplazo de este archivo. ya que no tiene la misma atencion al detalle que el fork de [dwm](https://github.com/Cat-Not-Furry/Configurations/tree/main/dwm-full) que esta en este repo.
**Aun así, si deseas probar la configuración que tengo puedes hacer lo siguiente...**

**Si gustas puedes pasarte por el [sitio oficial](https://i3wm.org/docs/userguide.html) a ver la guía de usuario**

## Variables de entorno (X11)

Al iniciar i3 se aplican las mismas variables que en `hyprland/hyperland/scripts/x11-environment.sh`:

| Variable | Valor |
|----------|-------|
| `XDG_SESSION_TYPE` | `x11` |
| `GDK_BACKEND` | `x11` |
| `QT_QPA_PLATFORM` | `xcb` |
| `QT_QPA_PLATFORMTHEME` | `qt5ct` |
| `XDG_CURRENT_DESKTOP` | `i3` |

- **`conf.d/00-env.conf`** — al arrancar i3 ejecuta `scripts/i3-environment.sh` (env + cava X11 + `dbus-update-activation-environment`; no toca `~/.bashrc` en cada reload).
- **`session/binscripts/sdm`** — script de consola (no es un display manager): antes de `startx` ejecuta `x11-environment.sh` (bashrc X11 + env + cava + mata restos Wayland). El equivalente Hyprland ocurre en `hypr-environment.sh` + `hypr-session-init.sh`.
- Al entrar en i3 se terminan procesos Wayland/Hyprland huérfanos (waybar, ignis, swaync, cava, etc.); Hyprland hace lo propio con restos X11 vía `hypr-session-init.sh`.

Manual:

```bash
./hyprland/hyperland/scripts/x11-environment.sh && source ~/.bashrc
```

Estado de sesión: `~/.cache/hypr/session-mode`.

## Temas i3 (classic / iceberg)

| Tema | Ventanas (gaps/bordes) | Barra |
|------|------------------------|-------|
| `classic` | Verde (#005818) | bumblebee-bar-classic.conf |
| `iceberg` | Foco `#e2e4ea`, sin foco `#000000` | Workspaces `#565f75` (bumblebee-bar-iceberg.conf) |

`apply-i3-theme.sh` **reemplaza** `07-gaps_borders.conf` y `05-bbar.conf` copiando desde `conf.d/themes/`. Al cambiar de tema reinicia i3 para repintar ventanas abiertas.

Por defecto en `cnf-bin/config.toml`: `[i3] theme = "classic"`. Tras deploy o al arrancar i3 se ejecuta `apply-i3-theme.sh`.

Cambio manual:

```bash
~/.config/i3/scripts/apply-i3-theme.sh classic   # verde original
~/.config/i3/scripts/apply-i3-theme.sh iceberg   # iceberg dark
```

Tmux en sesión X11 usa `tmux/colors/gray.conf` (misma base #161821 que el tema i3 iceberg).

Probar **polybar** en lugar de bumblebee: menú dmenu → Utilidades → Pantallas → Barra, o:

```bash
~/.config/i3/scripts/toggle-status-bar.sh polybar    # prueba
~/.config/i3/scripts/toggle-status-bar.sh bumblebee  # volver
```

## Bandeja del sistema (nm-applet, Bluetooth, CopyQ)

Los iconos de red, Bluetooth y portapapeles van en la **bandeja de i3bar** al **extremo derecho** (`tray_output primary` en `conf.d/05-bbar.conf`). Los módulos de bumblebee-status quedan a su izquierda.

| Momento | Qué ocurre |
|---------|------------|
| Arranque i3 | `scripts/i3-environment.sh` — env X11, mata restos Wayland, dunst, portales, polkit |
| ~5 s después | `scripts/ensure-tray-services.sh` — espera `i3bar` y arranca nm-applet, blueman-applet, copyq |

`00-exec.conf` usa `exec_always` con ese script para que también se restauren tras `i3-msg reload` si faltan.

Manual (sesión i3 activa, tras deploy):

```bash
./hyprland/hyperland/scripts/deploy-configs.sh --config   # o solo la parte i3
~/.config/i3/scripts/ensure-tray-services.sh   # ruta en el sistema tras deploy
```

Si no ves iconos: confirma con `pgrep -xa i3bar`, `pgrep -xa nm-applet`, `pgrep -af blueman-applet` y que `05-bbar.conf` sigue activo (no polybar en paralelo con otra `tray_output`).

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
- **maim**, **slop**, **xclip** (capturas X11: región e pantalla completa)
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
# Capturas X11: maim slop xclip (en lugar de flameshot)
```



### Arch Linux

```bash
sudo pacman -S i3-gaps alacritty rofi dunst polkit-kde-agent \
  xdg-desktop-portal xdg-desktop-portal-gtk feh ttf-hack-nerd \
  brightnessctl pulseaudio-utils xss-lock network-manager-applet \
  blueman libinput-gestures xorg-setxkbmap
# Opcionales (oficiales)
sudo pacman -S flameshot polybar cmus lm_sensors dmenu
# Capturas X11: maim slop xclip
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
> i3-gaps no está disponible en repositorios oficiales de Alpine, se recomiendo buscar parches para i3wm.



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
pkg install x11-wm/i3
pkg install alacritty rofi dunst feh brightnessctl
```

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

Atajos que dependen de scripts del repo (rutas tras `deploy-configs.sh`):

- `i3-wm/scripts/lock.sh` — bloqueo (`xss-lock`)
- `i3-wm/scripts/dmenu-script.sh`, `dmenu-script1.sh` — lanzadores
- `cnf-bin/bin/toggle-keyboard.sh` o `~/.local/bin/toggle-keyboard.sh` — teclado
- `eww/launch.sh` — widgets eww
- `life_fondo`, `dead_fondo.sh` — fondos animados (opcional)
- `touchpad` — configuración del touchpad (script/alias local)

Si no usas alguna función, comenta la línea en el `conf.d/` correspondiente.

> [!NOTE]
> 
> Revisa los ejecutables y rutas.


- Para que los atajos de volumen y brillo funcionen, verifica que los comandos `pactl` y `brightnessctl` estén instalados y que los nombres de los sinks/dispositivos sean correctos.

## Cómo fusionar la configuración (monolítica avanzada)

En lugar de reemplazar tu `config` de i3 instalado por el del sistema, **fusiona** fragmentos del repo.

### Instrucciones

1. Respalda tu config actual (ruta típica del paquete i3, no del repo):

   ```bash
   cp ~/.config/i3/config ~/.config/i3/config.bak
   ```

2. Abre tu config y los archivos del repo (`i3-wm/config`, `i3-wm/conf.d/`, `i3-wm/scripts/`).

3. Copia solo lo que necesites (workspaces, binds, `bar { }`, gaps, `exec`).

4. **Bandeja:** no añadas `nm-applet`/`blueman` sueltos en `exec` si usas `ensure-tray-services.sh` + `tray_output primary`.

5. Prueba: `i3-msg reload` y revisa `i3-msg -t get_version` / errores en el log.

### Despliegue completo (recomendado)

Desde el clone del repo:

```bash
./hyprland/hyperland/scripts/deploy-configs.sh --config
i3-msg reload   # si ya estás en sesión i3
```

Eso copia `i3-wm/` → `~/.config/i3/` (sin este README).

> [!NOTE]
>
> Recuerda: **tú eres responsable de los cambios**, así que ten siempre una copia de seguridad funcional.

## Atajos que agregue

Si gustas puedes pasarte por el [sitio oficial](https://i3wm.org/docs/userguide.html) a ver la guia de usuario
