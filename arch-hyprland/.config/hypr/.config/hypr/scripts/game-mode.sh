#!/bin/bash

# Function to set gaming mode
set_gaming_mode() {
    # Disable all monitors except DP-1
    hyprctl keyword monitor "HDMI-A-1, disable"
    hyprctl keyword monitor "DP-2, disable"
    hyprctl keyword monitor "HDMI-A-2, disable"
    
    # Set DP-1 to gaming mode settings
    hyprctl keyword monitor "DP-1, 2560x1440@360, 0x0, 1, vrr, 2"

    # Set workspaces 1-5 to DP-1
    for i in {1..5}; do
        hyprctl keyword workspace "$i, monitor:DP-1"
    done
    
    # Set workspace 1 as default for DP-1
    hyprctl keyword workspace "1, monitor:DP-1, default:true"

    hyprctl dispatch workspace 1
    
    echo "Gaming mode activated"
}

# Function to set regular mode
set_regular_mode() {
    hyprctl keyword monitor "HDMI-A-1, 3840x2160@120, 1080x0, 1, vrr, 2"
    hyprctl keyword monitor "DP-2, 1920x1080@60, 0x0, 1, transform, 1"
    hyprctl keyword monitor "DP-1, 2560x1440@120, 4920x0, 1, transform, 3"
    hyprctl keyword monitor "HDMI-A-2, disable"

    # Restore original workspace configuration
    hyprctl keyword workspace "1, monitor:HDMI-A-1, default:true"
    hyprctl keyword workspace "2, monitor:HDMI-A-1"
    hyprctl keyword workspace "3, monitor:HDMI-A-1"
    hyprctl keyword workspace "4, monitor:DP-2, default:true"
    hyprctl keyword workspace "5, monitor:DP-1, default:true"
    
    echo "Regular mode activated"
}

# Check current mode
# if hyprctl monitors | grep -q "2560x1440@360"; then
if ! hyprctl monitors | grep "HDMI-A-1"; then
    # Currently in gaming mode, switch to regular mode
    echo "Currently in gaming mode, switch to regular mode"
    set_regular_mode
else
    # Currently in regular mode or unknown state, switch to gaming mode
    echo "Currently in regular mode or unknown state, switch to gaming mode"
    set_gaming_mode
fi