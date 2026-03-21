#!/bin/bash

DIR="$HOME/.config/dwmbar/scripts"
while [[ true ]]; do
  fecha_hora="$($DIR/clock.sh)"
  mem="$($DIR/memoria.sh)"
  #wifi_ip=$($DIR/wifi_ip.sh)
  disk_root=$($DIR/disk_root.sh)
  vol=$($DIR/volume.sh)
  #ip_public="󰩟 :$(curl ifconfig.me)"
  #disk_home=$($DIR/disk_home.sh)
  #batt=$($DIR/batt.sh)
  temp=$($DIR/temp.sh)
  host=$($DIR/host.sh)
  cpu=$($DIR/cpu.sh)
  bate=$($DIR/bateria.sh)
  bllo=$($DIR/brillo.sh)
  xsetroot -name "$cpu $temp $mem $disk_root $bate $bllo $host $fecha_hora"
  sleep 1
done
