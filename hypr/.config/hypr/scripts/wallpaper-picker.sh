#!/bin/bash
# Save as: ~/.config/hypr/scripts/wallpaper-picker.sh

WALLPAPER_DIR="$HOME/Pictures/Wallpapers"

if [ ! -d "$WALLPAPER_DIR" ]; then
    notify-send "Error" "Wallpaper directory not found: $WALLPAPER_DIR"
    exit 1
fi

cd "$WALLPAPER_DIR" || exit

# ==========================================
# THE MAGIC RULE: Did Quickshell hand us a file?
# ==========================================
if [ -n "$1" ]; then
    # YES: Quickshell passed a file, so we skip Rofi and use it!
    SELECTED=$(basename "$1")
else
    # NO: You ran this from the terminal/shortcut, so open Rofi!
    if ! command -v rofi &> /dev/null; then
        notify-send "Error" "Rofi is not installed"
        exit 1
    fi
    WALLPAPERS=$(find . -maxdepth 1 -type f \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" -o -iname "*.webp" \) -printf "%f\n" | sort)
    if [ -z "$WALLPAPERS" ]; then
        notify-send "Error" "No wallpapers found in $WALLPAPER_DIR"
        exit 1
    fi
    SELECTED=$(echo "$WALLPAPERS" | rofi -dmenu -i -p "Select Wallpaper")
fi

# ==========================================
# YOUR EXACT ORIGINAL LOGIC 
# ==========================================
if [ -n "$SELECTED" ]; then
    WALLPAPER_PATH="$WALLPAPER_DIR/$SELECTED"
    
    "$HOME/.local/bin/rice" --wallpaper "$WALLPAPER_PATH"
    
    # 3. Quickshell recolours live: matugen's post_hook runs `qs ipc call theme reload` and the
    #    colours animate in place, so restarting it (which also dropped notifications) isn't needed.
    # if pgrep -x "quickshell" > /dev/null; then
    #     killall quickshell
    #     sleep 0.2
    #     quickshell > /dev/null 2>&1 & disown
    # fi
    
    notify-send "Wallpaper Changed" "$SELECTED"
fi