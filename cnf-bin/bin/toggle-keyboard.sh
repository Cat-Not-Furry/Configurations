#!/bin/bash

DEVICE=$(xinput list --id-only "AT Translated Set 2 keyboard")
MASTER=$(xinput list | grep "Virtual core keyboard" | grep -oP 'id=\K[0-9]+')

if xinput list | grep "id=$DEVICE" | grep -qi floating; then
  xinput reattach "$DEVICE" "$MASTER"
else
  xinput float "$DEVICE"
fi
