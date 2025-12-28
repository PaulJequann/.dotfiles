#!/bin/bash

# Get all connected monitors
monitors=$(hyprctl monitors | grep "Monitor" | awk '{print $2}')

# Loop through each monitor and disable them, excluding "HDMI-A-2"
for monitor in $monitors; do
    if [ "$monitor" != "HDMI-A-2" ]; then
        hyprctl keyword monitor "$monitor, disable"
    fi
done

# Enable HDMI-A-2
result=$(hyprctl keyword monitor "HDMI-A-2, 1920x1080@120, 0x0, 1")

# If the result is "ok", issue the command to switch to workspace 6
if [[ $result == *"ok"* ]]; then
    hyprctl dispatch workspace 6
fi
