# session/binscripts

Los scripts de esta carpeta se migraron en la fase C; los legacy de hardware se eliminaron en la fase F.

| Antes | Ahora |
|-------|-------|
| Scripts diarios | [`cnf-bin/bin/`](../cnf-bin/bin/) |
| `monitor`, `cpu-mode`, … | [`utilidades/`](../utilidades/) |
| `brillo`, `bateria`, `temperatura`, `frecuencia` | **`cnf-info`** (flags; no hay scripts sueltos en `cnf-bin/bin/`) |

Esta carpeta queda vacía salvo este README (referencia histórica para deploy de `session/`).

Ver [`cnf-bin/README.md`](../cnf-bin/README.md) y [`cnf-bin/MIGRATION.md`](../cnf-bin/MIGRATION.md).
