# Atajos tmux

Referencia interactiva (desde **cualquier** directorio):

```bash
tmux-help                              # alias en bashrc
~/.config/tmux/scripts/atajos.sh all
~/.config/hypr/scripts/tmux-atajos.sh nav
```

## Prefijo: **Alt+a** (no Ctrl)

Evita conflictos con foot, readline y nvim. Tras **Alt+a**, suelta y pulsa la tecla del comando.

| Sin prefijo | Acción |
|-------------|--------|
| **Alt+Space** → suelta → flecha | Navegar splits (paneles) |
| **Alt+Shift+Space** → suelta → flecha | Cambiar pestañas tmux |
| **Alt+\\** | Split horizontal |
| **Alt+-** | Split vertical |
| **Alt+x** | Cerrar panel (confirma) |

| Alt+a luego… | Acción |
|--------------|--------|
| `\|` / `-` | Split H / V |
| `d` | Desconectar sesión |
| `c` | Nueva ventana |
| `r` | Recargar config |
| `?` | Ayuda tmux |

Barra: `sesión | pac/aur/flat | HH:MM`

Sin TPM ni plugins externos — todo está en `tmux.conf`.
