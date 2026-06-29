#!/usr/bin/env bash
# Utilidades compartidas para *-manager: servicios bajo demanda (sesión), sin enable al arranque.

resolve_cnf_bin_root() {
  if [[ -n "${CNF_BIN_ROOT:-}" && -d "$CNF_BIN_ROOT" ]]; then
    printf '%s\n' "$CNF_BIN_ROOT"
    return 0
  fi
  if [[ -d "${HOME}/.config/cnf-bin" ]]; then
    printf '%s\n' "${HOME}/.config/cnf-bin"
    return 0
  fi
  if [[ -d "${HOME}/Games/configurations/shared/cnf-bin" ]]; then
    printf '%s\n' "${HOME}/Games/configurations/shared/cnf-bin"
    return 0
  fi
  if [[ -d "${HOME}/hyprland/cnf-bin" ]]; then
    printf '%s\n' "${HOME}/hyprland/cnf-bin"
    return 0
  fi
  return 1
}

manager_check_root() {
  if [[ $EUID -eq 0 ]]; then
    echo "No ejecutes este script como root. Usa tu usuario normal." >&2
    exit 1
  fi
}

manager_service_active() {
  systemctl is-active --quiet "$1" 2>/dev/null
}

# Inicia unidad systemd solo para la sesión actual (no habilita en boot).
manager_session_start() {
  local unit="$1"
  if manager_service_active "$unit"; then
    return 0
  fi
  sudo systemctl start "$unit"
  manager_service_active "$unit"
}

manager_session_stop() {
  local unit="$1"
  if ! manager_service_active "$unit"; then
    return 0
  fi
  sudo systemctl stop "$unit"
  ! manager_service_active "$unit"
}

manager_session_start_many() {
  local unit ok=0
  for unit in "$@"; do
    if manager_session_start "$unit"; then
      ok=$((ok + 1))
    fi
  done
  [[ "$ok" -eq "$#" ]]
}

manager_session_stop_many() {
  local unit ok=0
  for unit in "$@"; do
    if manager_session_stop "$unit"; then
      ok=$((ok + 1))
    fi
  done
  [[ "$ok" -eq "$#" ]]
}

# Habilitar/deshabilitar arranque en boot (explícito, no parte de start).
manager_boot_enable() {
  local unit
  for unit in "$@"; do
    sudo systemctl enable "$unit"
  done
}

manager_boot_disable() {
  local unit
  for unit in "$@"; do
    sudo systemctl disable "$unit"
  done
}
