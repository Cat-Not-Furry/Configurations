#!/bin/bash
cpu_freq=$(awk '{printf "%.1fGHz\n", $1/1000000}' /sys/devices/system/cpu/cpu0/cpufreq/scaling_cur_freq 2>/dev/null)
if [ -z "$cpu_freq" ]; then
  cpu_freq=$(lscpu | grep "CPU MHz" | awk '{print $3/1000 "GHz"}')
fi
echo " $cpu_freq"
