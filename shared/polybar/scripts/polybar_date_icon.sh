#!/bin/bash

# Obtiene la hora actual en formato de 12 horas (01, 02, ..., 12)
hour=$(date '+%I')

# Selecciona el ícono basado en la hora
case "$hour" in
"01") icon="󱑋" ;;
"02") icon="󱑌" ;;
"03") icon="󱑍" ;;
"04") icon="󱑎" ;;
"05") icon="󱑏" ;;
"06") icon="󱑐" ;;
"07") icon="󱑑" ;;
"08") icon="󱑒" ;;
"09") icon="󱑓" ;;
"10") icon="󱑔" ;;
"11") icon="󱑕" ;;
"12") icon="󱑖" ;;
*) icon="" ;; # Un ícono por defecto si algo falla
esac

# Formato de fecha y hora (similar al que ya tenías en tu config)
date=$(date "+%a %d/%m/%y")
time=$(date "+%H:%M:%S")

# Imprime el resultado para que Polybar lo muestre
echo "$date $icon $time"
