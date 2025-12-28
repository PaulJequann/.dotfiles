#!/bin/bash

screen1="HDMI-A-1"
screen2="DP-2"
screen3="DP-1"
screen4="HDMI-A-2"

hyprctl keyword monitor $screen4, disable
hyprctl keyword monitor $screen1, 3840x2160@120, 1080x0, 1, bitdepth, 10, vrr, 1
hyprctl keyword monitor $screen2, 1920x1080@60, 0x0 , 1, transform, 1
hyprctl keyword monitor $screen3, 1920x1080@60, 4920x0, 1, transform, 3

# Switch to workspace 1
hyprctl dispatch workspace 1