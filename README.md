Método 2: Usar Git con Sparse Checkout (recomendado para usuarios avanzados)
Este método usa Git desde la terminal y es ideal si ya tienes Git instalado o si necesitas hacer esto con frecuencia.

Abre tu terminal y ejecuta estos comandos:

bash
# Clona el repositorio sin descargar los archivos
git clone --filter=blob:none --no-checkout https://github.com/usuario/repositorio.git
cd repositorio

# Habilita sparse checkout
git sparse-checkout init --cone

# Especifica qué carpeta quieres descargar
git sparse-checkout set ruta/a/carpeta

# Descarga solo los archivos de esa carpeta
git checkout
Este método descarga únicamente los archivos necesarios, no todo el historial del repositorio 
