#!/usr/bin/env bash
# Umbrales: warning >= 70% del límite, critical >= 85% (15% margen al tope).
threshold_class() {
  local value="$1"
  local limit="$2"
  awk -v v="$value" -v lim="$limit" 'BEGIN {
    if (lim <= 0) { print ""; exit }
    pct = (v / lim) * 100
    if (pct >= 85) print "critical"
    else if (pct >= 70) print "warning"
    else print ""
  }'
}
