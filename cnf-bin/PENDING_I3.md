# Pendiente — validación i3 / X11

Estos casos están **cableados en el repo** (fase D) pero **no probados** hasta cambiar de sesión a i3/X11.

## Barra bumblebee

- [ ] `bumblebee-status/launch.sh` arranca sin errores (vía `i3-wm/conf.d/05-bbar.conf`)
- [ ] Iconos de bandeja: `nm-applet`, `blueman-applet`, `copyq` tras `i3-wm/scripts/ensure-tray-services.sh`
- [ ] Módulos: `media cpu sensors memory disk battery pipewire brightness keyboard hostname datetime shell:kbd`
- [ ] `shell:kbd` muestra `cnf-info --kbdlight` (solo lectura)
- [ ] `cmus` **no** está en la barra (módulo conservado en repo como reserva)
- [ ] Tema `iceberg` carga correctamente

**Archivos:** [`i3-wm/conf.d/05-bbar.conf`](../i3-wm/conf.d/05-bbar.conf), [`bumblebee-status/launch.sh`](../bumblebee-status/launch.sh)

## Atajos i3

- [ ] `XF86MonBrightnessUp/Down` → `cnf-info --brillo +/-` ([`01-binds_media.conf`](../i3-wm/conf.d/01-binds_media.conf))
- [ ] `Super+Shift+t` → `toggle-keyboard.sh` (si está en keybinds)
- [ ] Módulo `keyboard` en barra bumblebee coherente con `toggle-keyboard.sh`

## Utilidades X11

- [ ] `monitor` / `monitor-wofi` desde [`utilidades/`](../utilidades/)
- [ ] `cpu-mode` con sudo si aplica

## Polybar legacy

- [ ] Sin cambios en esta migración; revisar solo si vuelves a usar polybar

## Cómo probar

```bash
# Tras deploy completo o --config
./hyperland/scripts/x11-environment.sh && source ~/.bashrc
startx   # o SDM → i3
i3-msg reload
# Observar barra superior y atajos de brillo/teclado
```

Cuando marques todo OK, puedes borrar este archivo o mover el checklist al README de bumblebee/i3.
