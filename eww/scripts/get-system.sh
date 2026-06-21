#!/usr/bin/env bash
set -euo pipefail

mode="${1:-}"
field="${2:-}"

case "$mode" in
  static)
    case "$field" in
      os)
        if [ -f /etc/os-release ]; then
          # shellcheck source=/dev/null
          . /etc/os-release
          echo "${PRETTY_NAME:-Arch Linux}"
        else
          echo "Arch Linux"
        fi
        ;;
      host)
        hostname
        ;;
      kernel)
        uname -r
        ;;
      wm)
        if command -v hyprctl >/dev/null 2>&1; then
          hyprctl version 2>/dev/null | head -1 | sed 's/.* Hyprland //; s/ .*//'
        else
          echo "Hyprland"
        fi
        ;;
      shell)
        basename "${SHELL:-/bin/bash}"
        ;;
      cpu)
        grep -m1 'model name' /proc/cpuinfo 2>/dev/null \
          | cut -d: -f2 \
          | sed 's/^ *//' \
          | sed 's/  */ /g' \
          || echo "N/A"
        ;;
      terminal)
        echo "foot"
        ;;
      *)
        echo "N/A"
        ;;
    esac
    ;;
  dynamic)
    case "$field" in
      uptime)
        read -r up _ </proc/uptime
        days=$(printf '%.0f' "${up}" | awk '{print int($1/86400)}')
        hours=$(printf '%.0f' "${up}" | awk '{print int(($1%86400)/3600)}')
        mins=$(printf '%.0f' "${up}" | awk '{print int(($1%3600)/60)}')
        if [ "$days" -gt 0 ]; then
          echo "${days}d ${hours}h ${mins}m"
        elif [ "$hours" -gt 0 ]; then
          echo "${hours}h ${mins}m"
        else
          echo "${mins}m"
        fi
        ;;
      ram)
        awk '/MemTotal/ {t=$2} /MemAvailable/ {a=$2} END {
          if (t > 0) printf "%.1f / %.1f GiB", (t-a)/1024/1024, t/1024/1024;
          else print "N/A"
        }' /proc/meminfo
        ;;
      disk)
        df -h / 2>/dev/null | awk 'NR==2 {print $3 " / " $2 " (" $5 ")"}'
        ;;
      *)
        echo "N/A"
        ;;
    esac
    ;;
  *)
    echo "N/A"
    ;;
esac
