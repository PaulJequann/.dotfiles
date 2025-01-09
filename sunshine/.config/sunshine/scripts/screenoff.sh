#!/bin/bash

# Get all connected monitors
monitors=$(hyprctl monitors all | grep "Monitor" | awk '{print $2}')

# Loop through each monitor and apply the command
for monitor in $monitors; do
    hyprctl keyword monitor "$monitor,highrr,auto,1"
done
