#!/usr/bin/env bash
# kexec desde menú Ignis: Enter + sudo en foot (sin --no-prompt).
# Uso: kexec-action.sh load|exec|full [PKG]
#   PKG opcional: linux-lts, linux-cnf, linux-zen, … (solo load/full)
set -uo pipefail

MODE="${1:-}"
PKG="${2:-}"

usage() {
    echo "Uso: $0 load|exec|full [PKG]"
}

fail() {
    echo "Error: $*"
    echo
    read -r -p "Pulse Enter para cerrar..."
    exit 1
}

confirm_continue() {
    local action_desc="$1"
    echo "ADVERTENCIA: acción kexec ($action_desc)."
    echo "Se pierde trabajo no guardado."
    echo "Kernel: $(uname -r)  Paquete: ${PKG}"
    echo "vmlinuz: ${VMLINUZ}"
    echo "initrd:  ${INITRD}"
    echo
    echo "Enter para continuar, Ctrl+C para cancelar."
    read -r
}

pause_end() {
    echo
    read -r -p "Pulse Enter para cerrar..."
}

resolve_pkg() {
    if [[ -n "$PKG" ]]; then
        return 0
    fi
    local kver
    kver="$(uname -r)"
    case "$kver" in
        *-lts*) PKG=linux-lts ;;
        *-cnf*) PKG=linux-cnf ;;
        *-zen*) PKG=linux-zen ;;
        *-hardened*) PKG=linux-hardened ;;
        *) PKG=linux ;;
    esac
}

if [[ "$MODE" != "load" && "$MODE" != "exec" && "$MODE" != "full" ]]; then
    usage
    exit 1
fi

if ! command -v kexec >/dev/null 2>&1; then
    fail "kexec no está instalado. Instale kexec-tools: sudo pacman -S kexec-tools"
fi

if [[ "$MODE" == "exec" ]]; then
    confirm_continue "ejecutar salto al kernel cargado"
    echo "Ejecutando: sudo systemctl kexec"
    sudo systemctl kexec || {
        pause_end
        exit 1
    }
    pause_end
    exit 0
fi

resolve_pkg

VMLINUZ="/boot/vmlinuz-${PKG}"
INITRD="/boot/initramfs-${PKG}.img"

if [[ ! -f "$VMLINUZ" ]]; then
    fail "No se encontró $VMLINUZ"
fi

if [[ ! -f "$INITRD" ]]; then
    fail "No se encontró $INITRD"
fi

case "$MODE" in
    load)
        confirm_continue "cargar kernel en memoria"
        echo "Ejecutando: sudo kexec -l \"$VMLINUZ\" --initrd=\"$INITRD\" --reuse-cmdline"
        sudo kexec -l "$VMLINUZ" --initrd="$INITRD" --reuse-cmdline || {
            pause_end
            exit 1
        }
        echo "Kernel cargado. Use «Ejecutar salto» (systemctl kexec) para reiniciar al instante."
        pause_end
        ;;
    full)
        confirm_continue "reinicio rápido (cargar y saltar)"
        echo "Ejecutando: sudo kexec -l ... --reuse-cmdline"
        echo "          sudo systemctl kexec"
        sudo kexec -l "$VMLINUZ" --initrd="$INITRD" --reuse-cmdline || {
            pause_end
            exit 1
        }
        sudo systemctl kexec || {
            pause_end
            exit 1
        }
        pause_end
        ;;
esac
