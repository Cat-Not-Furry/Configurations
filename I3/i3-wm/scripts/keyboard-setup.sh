#!/usr/bin/bash

id=$(xinput list | awk '/HID 04f3:0103/ && !/Consumer Control/ && !/System Control/' | grep -oP 'id=\K[0-9]+')
[ -n "$id" ] && setxkbmap -device "$id" -layout es -option lv3:ralt_switch
