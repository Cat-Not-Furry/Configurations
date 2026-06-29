# Mi  .bahsrc
### Por seguridad subi mi [.basrc](https://www.zeppelinux.es/bashrc-uso-de-los-archivos-bashrc-y-etc-bashrc/), ya que no me gustaria tener que investigar nuevamente.
Deberia estudiar... pero la proscrastinación es más fuerte.

## Dependencias necesarias
#### bash-completion
```
sudo pacman -S bash-completion
```
#### fzf
```
sudo pacman -S fzf  
```

#### fuck
```
sudo pacman -S thefuck
```
#### z
```
sudo pacman -S z
```
#### exa
```
sudo pacman -S exa
```
#### bat
```
sudo pacman -S bat
```
## alias
. = cd<br>
, = cd ..<br>
ls = lista con iconos<br>
ll = lista con iconos pero con '-l' y '-h'<br>
ver = bat 'versión mejorada de cat'

# sdm – Selector de entornos gráficos minimalista

`sdm` es un selector de entornos gráficos diseñado para sistemas minimalistas que no usan un gestor de pantalla (display manager) tradicional. Se ejecuta desde la consola (TTY) después de iniciar sesión y te permite elegir entre **i3** (X11) y **Hyprland** (Wayland), además de ofrecer acciones del sistema como suspender, hibernar, apagar o reiniciar.

## Características

- **Ligero**: no deja procesos en segundo plano. Solo se ejecuta mientras eliges una opción.
- **Recuerda la última sesión** (se guarda en `~/.last_session`).
- **Menú con colores** para una mejor experiencia visual.
- **Acciones del sistema**:
  - Suspender
  - Hibernar
  - Apagar
  - Reiniciar
  - Salir a la consola
- **Confirmación** antes de ejecutar acciones críticas.
- **Manejo de errores**: si la sesión falla, puedes volver al menú para corregir la configuración.
- **Fácil de personalizar**: puedes añadir más entornos o cambiar colores modificando el script.

## Requisitos

- **Bash** (shell por defecto en la mayoría de sistemas)
- **systemd** (para las acciones de apagado, reinicio, suspensión e hibernación)
- **i3** y/o **Hyprland** instalados y configurados
- **startx** (generalmente incluido en `xorg-xinit`)
- **fgconsole** (parte de `kbd`)

## Instalación

1. **Copia el script** a `/usr/local/bin/` (o cualquier otra ruta en tu `$PATH`):

   ```bash
   # Existe sdm.sh (antiguo) y sdm.new (nuevo solo renombre el que prefieras) Usa:
   # mv sdm.sh sdm  o mv sdm.new sdm
   sudo cp sdm /usr/local/bin/
   sudo chmod +x /usr/local/bin/sdm
   ```

2. **Asegúrate de que tu shell ejecute `sdm` al iniciar sesión**.
   Edita tu archivo de perfil (por ejemplo `~/.bash_profile` o `~/.profile`) y añade al final:

   ```bash
   # Selector de sesion de pantalla
   if [ -z "$DISPLAY" ] && [ -z "$WAYLAND_DISPLAY" ] && [ -t 0 ] && [ -z "$SSH_TTY" ]; then
     sdm
   fi
   ```

   

   Esto hará que después de ingresar tu usuario y contraseña en la consola, se ejecute automáticamente el selector.

3. **Si usas un shell diferente a Bash**, ajusta el archivo de perfil correspondiente (`.zprofile` para Zsh, etc.).

## Uso

Al iniciar sesión en una consola (TTY), verás un menú como este:

text

```bash
=====================================
        Selector de Entornos
=====================================
Última sesión: i3

1) i3 (X11)
2) Hyprland (Wayland)

3) Suspender
4) Hibernar
5) Apagar
6) Reiniciar
7) Salir a la consola

Opción [1-7]:
```



- **1** – Inicia i3 (X11)
- **2** – Inicia Hyprland (Wayland)
- **3** – Suspende el sistema (pide confirmación)
- **4** – Hiberna el sistema (pide confirmación)
- **5** – Apaga el sistema (pide confirmación)
- **6** – Reinicia el sistema (pide confirmación)
- **7** – Sale al shell de la consola (no inicia entorno gráfico)

Después de elegir una opción, el script lanzará el entorno seleccionado. Si la sesión falla (por error en la configuración), se te preguntará si quieres volver al menú para corregir el problema.

## Personalización

### Añadir más entornos

Puedes agregar fácilmente más entornos (por ejemplo, Sway, GNOME, etc.) editando el script:

1. Añade una nueva línea en el menú (en la función `show_menu`).
2. Agrega una nueva función que lance el entorno (similar a `start_i3` o `start_hyprland`).
3. Añade la opción en el `case` principal.

Ejemplo para añadir Sway:

bash

```bash
# En show_menu:
echo -e "${green}3) Sway (Wayland)${reset}"

# Función:
start_sway() {
    echo -e "${green}Iniciando Sway...${reset}"
    save_last_session "sway"
    exec sway
}

# En el case:
3)
    start_sway || handle_session_error
    ;;
```



### Cambiar colores

Las variables de color se definen al inicio del script. Puedes modificar los códigos ANSI o cambiar qué colores se usan en cada parte del menú.

### Quitar confirmación en acciones del sistema

Si prefieres que apagar, reiniciar, etc. se ejecuten sin preguntar, edita las funciones correspondientes (`do_poweroff`, `do_reboot`, `do_suspend`, `do_hibernate`) y elimina la llamada a `confirm_action`.

### No limpiar la pantalla

Por defecto, el script no limpia la pantalla para que veas el historial. Si quieres que limpie antes de mostrar el menú, descomenta la línea `# clear` dentro de la función `show_menu`.

## Solución de problemas

### El script no se ejecuta al iniciar sesión

- Verifica que tu archivo de perfil (`~/.bash_profile`, `~/.profile`, etc.) tenga `exec sdm` al final.
- Asegúrate de que `sdm` esté en una ruta incluida en `$PATH` (por ejemplo `/usr/local/bin`).
- En algunas configuraciones, Bash ignora `~/.bash_profile` si existe `~/.profile`. Puedes mover el contenido o crear un enlace simbólico.

### No se muestra la última sesión guardada

- Asegúrate de que el archivo `~/.last_session` existe y tiene permisos de lectura. Si nunca has elegido una sesión, se mostrará "Ninguna".
- Si el archivo existe pero no se muestra, ejecuta manualmente `cat ~/.last_session` para ver si contiene algún carácter extraño.

### Hyprland no arranca

- Asegúrate de que `XDG_RUNTIME_DIR` está definido (debería estarlo en una sesión de consola normal).

- Verifica que `seatd` está en ejecución o que tu usuario pertenece al grupo `seat` (opcional pero recomendado):

  bash

  ```bash
  sudo systemctl enable --now seatd
  sudo usermod -aG seat $USER
  ```

  

- Si usas NVIDIA, consulta la documentación de Hyprland sobre configuraciones necesarias.

### i3 no arranca con `startx /usr/bin/i3`

Puedes cambiar la función `start_i3` para que use tu `~/.xinitrc` en lugar de pasar el ejecutable directamente:

bash

```bash
start_i3() {
    echo -e "${green}Iniciando i3...${reset}"
    save_last_session "i3"
    exec startx -- vt$(fgconsole)
}
```

Y asegúrate de que `~/.xinitrc` contenga `exec i3` (o la línea que desees).
