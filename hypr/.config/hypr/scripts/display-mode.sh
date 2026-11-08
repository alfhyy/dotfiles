#!/bin/bash

case "$1" in
    "laptop")
        hyprctl keyword monitor "eDP-1, 1366x768@60, 0x0, 1"
        hyprctl keyword monitor "HDMI-A-1, disable"
        ;;
    "duplicate")
        hyprctl keyword monitor "eDP-1, 1366x768@60, 0x0, 1"
        hyprctl keyword monitor "HDMI-A-1, 2560x1440@60, auto, 1, mirror, eDP-1"
        ;;
    "extend")
        hyprctl keyword monitor "eDP-1, 1366x768@60, 0x0, 1"
        hyprctl keyword monitor "HDMI-A-1, 2560x1440@60, 1366x0, 1"
        ;;
    "external")
        # Disable laptop first so the 0x0 slot is empty!
        hyprctl keyword monitor "eDP-1, disable"
        hyprctl keyword monitor "HDMI-A-1, 2560x1440@60, 0x0, 1"
        ;;
esac