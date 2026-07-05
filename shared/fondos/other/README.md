# fondos/other — aviso de uso y responsabilidad

Esta carpeta contiene archivos **`.7z` cifrados** con fondos de escritorio de uso personal (principalmente **arte anime** / ilustración 2D). Los JPG **no** se suben al repositorio; solo los paquetes comprimidos.

## Contenido

| Archivo | Notas |
|---------|--------|
| `other-1.7z` … `other-6.7z` | Colección opcional de wallpapers; requiere contraseña para extraer |

Tras restaurar los fondos desde copia de seguridad, los archivos se vuelven a empaquetar con cifrado **7zAES**. La contraseña es la frase de aceptación indicada abajo.

## Aceptación de responsabilidad (obligatoria para extraer)

**Descomprimir estas imágenes es decisión y responsabilidad exclusiva de quien lo hace.**

Al introducir la contraseña y confirmar la extracción —por ejemplo pegando la clave con **Ctrl+C**, **Ctrl+V** y **Enter** en `7z`, un gestor de archivos o cualquier otra herramienta— **declaras que**:

1. Has leído y entendido este aviso.
2. Aceptas la responsabilidad sobre el uso, posesión y visualización del contenido en tu equipo.
3. Eres mayor de edad o cuentas con autorización legal en tu jurisdicción para manejar este material.
4. El mantenedor del repositorio **queda deslindado de toda responsabilidad** a partir de ese momento: no controla ni supervisa lo que hagas tras extraer los archivos.

La contraseña de los archivos reempaquetados será:

```text
acepto la responsabilidad
```

Escribir o pegar esa frase para desbloquear el `.7z` equivale a aceptar los puntos anteriores.

## Naturaleza del material (para logs, CI, mirrors y quien audite el repo)

- Se trata de **fondos de pantalla** para entornos Linux (i3, Hyprland, Ignis, etc.).
- El estilo es **anime / ilustración digital** (personajes en estilo japonés, coloquialmente “mona china”, “waifu”, etc.).
- Persiste un **estigma social** hacia este tipo de fondos en algunos entornos; eso no implica ilegalidad del material en sí.
- **No hay intención de distribuir contenido ilegal.** Es material artístico de wallpaper, comparable a fondos que circulan en comunidades de escritorio Linux.
- Los `.7z` existen para **no exponer imágenes en claro** en GitHub y para que solo quien acepte este aviso las extraiga.
- Si un escáner, bot o moderador marca la carpeta: revisar el contexto (dotfiles personales, archivos cifrados, sin imágenes en claro en el repo).

## Uso técnico (mantenedores)

Extraer (solo tras aceptar el aviso):

```bash
cd shared/fondos/other
for f in other-*.7z; do 7z x -p"acepto la responsabilidad" -y "$f"; done
```

Volver a empaquetar (sin subir JPG al repo):

```bash
cd shared/fondos/other
rm -f other-*.7z other-*.7z.xml
7z a -p"acepto la responsabilidad" -mhe=on other-1.7z ./*.jpg
# Repartir en varios .7z si hace falta (como antes)
```

> **Deploy:** `deploy-configs.sh --fondos` o `--fondos-all` copia wallpapers a `~/.config/fondos/` (sin README). `--fondos-all` incluye `other/` (`.7z` y archivos; sin `*.md`). Sin flags, los fondos no se tocan en deploy.

## Descargo final

El autor del repositorio proporciona la configuración y los archivos cifrados **tal cual**, sin garantías. El uso del contenido extraído es **bajo tu propio criterio y riesgo**. Si no estás de acuerdo, **no descomprimas** los `.7z`.
