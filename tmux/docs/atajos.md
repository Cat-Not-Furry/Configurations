# Atajos tmux

Referencia interactiva (como `nvim/docs/atajos.sh`):

```bash
# Desde el repo o tras deploy:
./scripts/tmux-atajos.sh          # todo
./scripts/tmux-atajos.sh nav      # Alt+Space / Alt+Shift+Space
./scripts/tmux-atajos.sh sesiones
```

Tras deploy: `~/.config/hypr/scripts/tmux-atajos.sh`

Resumen rápido:

| Secuencia | Acción |
|-----------|--------|
| **Ctrl+Space** | Prefijo tmux |
| **Alt+Space** → flecha | Navegar splits |
| **Alt+Shift+Space** → flecha | Cambiar pestañas |
| **Ctrl+Space** `r` | Recargar config |

Barra de estado: `user@host | sesión | pac:N aur:N flat:N | HH:MM` (actualizaciones cada hora).

Ver también [README.md](../../README.md) del repo.
