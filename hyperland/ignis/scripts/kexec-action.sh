#!/usr/bin/env bash
set -uo pipefail

MODE="${1:-}"
NO_PROMPT=false

if [[ "${2:-}" == "--no-prompt" || "${3:-}" == "--no-prompt" ]]; then
    NO_PROMPT=true
fi

usage() {
    echo "Uso: $0 load|exec|full [--no-prompt]"
}

fail() {
    echo "Error: $*"
    echo
    read -r -p "Pulse Enter para cerrar..."
    exit 1
}

confirm_warning() {
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

if [[ "$MODE" != "load" && "$MODE" != "exec" && "$MODE" != "full" ]]; then
    usage
    exit 1
fi

if ! command -v kexec >/dev/null 2>&1; then
    fail "kexec no está instalado. Instale kexec-tools: sudo pacman -S kexec-tools"
fi

KVER="$(uname -r)"
case "$KVER" in
    *-lts*) PKG=linux-lts ;;
    *-zen*) PKG=linux-zen ;;
    *-hardened*) PKG=linux-hardened ;;
    *) PKG=linux ;;
esac

VMLINUZ="/boot/vmlinuz-${PKG}"
INITRD="/boot/initramfs-${PKG}.img"

if [[ ! -f "$VMLINUZ" ]]; then
    fail "No se encontró $VMLINUZ"
fi

if [[ ! -f "$INITRD" ]]; then
    fail "No se encontró $INITRD"
fi

maybe_confirm() {
    local action_desc="$1"
    if [[ "$NO_PROMPT" != "true" ]]; then
        confirm_warning "$action_desc"
    fi
}

case "$MODE" in
    load)
        maybe_confirm "cargar kernel en memoria"
        echo "Ejecutando: sudo kexec -l \"$VMLINUZ\" --initrd=\"$INITRD\" --reuse-cmdline"
        sudo kexec -l "$VMLINUZ" --initrd="$INITRD" --reuse-cmdline || {
            pause_end
            exit 1
        }
        echo "Kernel cargado. Use «Ejecutar salto (kexec -e)» para reiniciar al instante."
        if [[ "$NO_PROMPT" != "true" ]]; then
            pause_end
        fi
        ;;
    exec)
        maybe_confirm "ejecutar salto al kernel cargado"
        echo "Ejecutando: sudo kexec -e"
        sudo kexec -e || {
            pause_end
            exit 1
        }
        if [[ "$NO_PROMPT" != "true" ]]; then
            pause_end
        fi
        ;;
    full)
        maybe_confirm "reinicio rápido (cargar y saltar)"
        echo "Ejecutando: sudo kexec -l ... && sudo kexec -e"
        sudo kexec -l "$VMLINUZ" --initrd="$INITRD" --reuse-cmdline || {
            pause_end
            exit 1
        }
        sudo kexec -e || {
            pause_end
            exit 1
        }
        if [[ "$NO_PROMPT" != "true" ]]; then
            pause_end
        fi
        ;;
esac
