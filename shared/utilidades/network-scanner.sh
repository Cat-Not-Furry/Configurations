#!/usr/bin/env bash

# Script: network-scanner.sh
# Descripción: Escanea la red cada 2 minutos usando arp-scan

for _bootstrap in \
  "${HOME}/.config/cnf-bin/lib/bootstrap-session-user.sh" \
  "${HOME}/Games/configurations/shared/cnf-bin/lib/bootstrap-session-user.sh" \
  "${HOME}/hyprland/cnf-bin/lib/bootstrap-session-user.sh"; do
  if [[ -f "$_bootstrap" ]]; then
    # shellcheck source=/dev/null
    source "$_bootstrap"
    bootstrap_session_user "$0" "$@"
    break
  fi
done
if ! declare -F require_session_user >/dev/null 2>&1; then
  echo "bootstrap-session-user.sh no encontrado; despliega shared/cnf-bin/lib." >&2
  exit 1
fi

# Colores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Función para mostrar timestamp
timestamp() {
  echo -e "${BLUE}[$(date '+%Y-%m-%d %H:%M:%S')]${NC}"
}

# Verificar si arp-scan está instalado (instalar manualmente; sin sudo pacman automático)
if ! command -v arp-scan &>/dev/null; then
  echo -e "$(timestamp) ${RED}arp-scan no está instalado.${NC}"
  echo -e "$(timestamp) ${YELLOW}Instálalo manualmente: pacman -S arp-scan${NC}"
  exit 1
fi

echo -e "$(timestamp) ${GREEN}Iniciando escaneo de red cada 5 segundos${NC}"
echo -e "$(timestamp) ${YELLOW}Presiona Ctrl+C para detener${NC}"

# Bucle infinito cada 2 minutos
while true; do
  echo -e "\n$(timestamp) ${GREEN}=== ESCANEANDO RED ===${NC}"

  # Ejecutar arp-scan con sudo
  sudo arp-scan --localnet

  # Esperar 2 minutos (120 segundos)
  echo -e "$(timestamp) ${YELLOW}Esperando 5 segundos para próximo escaneo...${NC}"
  sleep 5
done
