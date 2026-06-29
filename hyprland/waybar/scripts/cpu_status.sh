#!/usr/bin/env bash
# CPU: uso % + frecuencia % del turbo + GHz (núcleo 0). Umbrales 70%/85%.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib/threshold_class.sh
source "$SCRIPT_DIR/lib/threshold_class.sh"

CACHE="/tmp/waybar-cpu.usage-${USER:-$(id -u)}"
cache_dir="${XDG_CACHE_HOME:-$HOME/.cache}/waybar"
if mkdir -p "$cache_dir" 2>/dev/null && [ -w "$cache_dir" ]; then
  CACHE="$cache_dir/cpu.usage"
fi

read_cpu_times() {
  awk '/^cpu / {print $2+$3+$4, $5; exit}' /proc/stat
}

if [ -f "$CACHE" ]; then
  read -r prev_busy prev_idle <"$CACHE" || prev_busy=0 prev_idle=0
else
  prev_busy=0
  prev_idle=0
fi

read -r busy idle < <(read_cpu_times)
echo "$busy $idle" >"$CACHE"

total=$((busy - prev_busy + idle - prev_idle))
usage=0
if [ "$total" -gt 0 ]; then
  usage=$(( (busy - prev_busy) * 100 / total ))
fi

# Núcleo 0 (como polybar / comando frecuencia)
core_khz=0
if [ -r /sys/devices/system/cpu/cpu0/cpufreq/scaling_cur_freq ]; then
  core_khz=$(cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_cur_freq)
elif [ -r /sys/devices/system/cpu/cpu0/cpufreq/cpuinfo_cur_freq ]; then
  core_khz=$(cat /sys/devices/system/cpu/cpu0/cpufreq/cpuinfo_cur_freq)
else
  mhz=$(awk -F': ' '/cpu MHz/ {print $2; exit}' /proc/cpuinfo 2>/dev/null || echo 0)
  core_khz=$(awk -v m="$mhz" 'BEGIN {printf "%d", m * 1000}')
fi

turbo_khz=$(cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_max_freq 2>/dev/null || echo 0)
if [ -z "$turbo_khz" ] || [ "$turbo_khz" -eq 0 ]; then
  turbo_khz=$(cat /sys/devices/system/cpu/cpu0/cpufreq/cpuinfo_max_freq 2>/dev/null || echo "$core_khz")
fi
if [ -z "$turbo_khz" ] || [ "$turbo_khz" -eq 0 ]; then
  turbo_khz=$core_khz
fi

class_usage=$(threshold_class "$usage" 100)
class_freq=$(threshold_class "$core_khz" "$turbo_khz")

class=""
if [ "$class_usage" = "critical" ] || [ "$class_freq" = "critical" ]; then
  class="critical"
elif [ "$class_usage" = "warning" ] || [ "$class_freq" = "warning" ]; then
  class="warning"
fi

if [ "$class" = "critical" ]; then
  icon="󰓅 "
elif [ "$class" = "warning" ]; then
  icon="󰾅 "
else
  icon="󰾆 "
fi

python3 - <<PY
import json
usage = ${usage}
core_khz = ${core_khz}
turbo_khz = ${turbo_khz}
freq_ghz = core_khz / 1_000_000
turbo_ghz = turbo_khz / 1_000_000
freq_pct = int(core_khz * 100 / turbo_khz) if turbo_khz else 0
print(json.dumps({
    "text": f"${icon}{usage}% {freq_ghz:.1f}GHz",
    "class": "${class}",
    "tooltip": (
        f"Uso CPU: {usage}%\\n"
        f"Frecuencia (núcleo 0): {freq_ghz:.1f} GHz ({freq_pct}% del turbo)\\n"
        f"Turbo máx: {turbo_ghz:.1f} GHz\\n"
        f"Naranja ≥70% · Rojo ≥85% del límite"
    ),
    "percentage": usage,
}, ensure_ascii=False))
PY
