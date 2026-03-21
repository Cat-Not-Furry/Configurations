#!/bin/bash
storage=$(df -h / | awk 'NR==2 {print $3 "/" $2}')
icon=""
echo "$icon $storage"
