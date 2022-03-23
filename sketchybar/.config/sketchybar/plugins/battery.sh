#!/bin/bash

BATT_PERCENT=$(pmset -g batt | grep -Eo "\d+%" | cut -d% -f1)
CHARGING=$(pmset -g batt | grep "AC Power")

if [[ $CHARGING != "" ]]; then
    sketchybar --set $NAME label.color=0xFFe8bd54
else 
    sketchybar --set $NAME label.color=0xFFFFFFFF
fi 
sketchybar --set $NAME label="  $BATT_PERCENT%"

  
