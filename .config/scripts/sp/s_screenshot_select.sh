#!/usr/bin/env bash
# ~/.config/scripts/sp/s_screenshot_select.sh

SAVE_DIR="$HOME/Pictures/Screenshots"
mkdir -p "$SAVE_DIR"

FILE_NAME="screenshot_$(date +'%Y%m%d_%H%M%S').png"
SAVE_PATH="$SAVE_DIR/$FILE_NAME"

# Instantly clear HUD and drop back to normal typing before capture
makoctl dismiss -a
hyprctl dispatch submap reset
sleep 0.15

# Capture interactive selection
GEOM=$(slurp)
[ -z "$GEOM" ] && exit 0
grim -g "$GEOM" "$SAVE_PATH"

# Clipboard & notification
if [ -f "$SAVE_PATH" ]; then
    wl-copy < "$SAVE_PATH"
    notify-send -a "screenshot" -i "$SAVE_PATH" -t 3000 "Captured Selection" "Saved and copied to clipboard."
fi
