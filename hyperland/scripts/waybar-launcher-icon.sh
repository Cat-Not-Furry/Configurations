#!/usr/bin/env bash
# Icono de distro para Waybar (Nerd Font / Font Awesome)

if [ -f /etc/os-release ]; then
  # shellcheck disable=SC1091
  source /etc/os-release
fi

ID="${ID:-unknown}"
ID_LIKE="${ID_LIKE:-}"

icon_for() {
  case "$1" in
    arch|endeavouros|cachyos|garuda) printf '\uf303' ;;
    debian) printf '\uf306' ;;
    ubuntu|pop|linuxmint|elementary) printf '\uf31b' ;;
    fedora|nobara) printf '\uf30a' ;;
    nixos) printf '\uf313' ;;
    manjaro) printf '\uf312' ;;
    opensuse*|sles) printf '\uf314' ;;
    gentoo) printf '\uf30d' ;;
    alpine) printf '\uf300' ;;
    *) printf '\uf17c' ;;
  esac
}

for token in $ID $ID_LIKE; do
  token="${token,,}"
  case "$token" in
    arch|debian|ubuntu|fedora|nixos|manjaro|endeavouros|gentoo|alpine|cachyos|garuda|pop|linuxmint|elementary|nobara)
      icon_for "$token"
      exit 0
      ;;
    opensuse*|sles)
      icon_for "$token"
      exit 0
      ;;
  esac
done

icon_for "$ID"
