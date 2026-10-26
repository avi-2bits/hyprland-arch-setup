#!/usr/bin/env bash
# ~/.config/scripts/sp/a_screenshot_active.sh

SAVE_DIR="$HOME/Pictures/Screenshots"
mkdir -p "$SAVE_DIR"

FILE_NAME="screenshot_$(date +'%Y%m%d_%H%M%S').png"
SAVE_PATH="$SAVE_DIR/$FILE_NAME"

# 1. Give the Mako HUD a tiny moment to slide out of view
sleep 0.15

# 2. Get the active window's JSON layout from hyprctl
ACTIVE_WINDOW_JSON=$(hyprctl activewindow -j)

# 3. Check if we actually have an active window focused
if [ "$(echo "$ACTIVE_WINDOW_JSON" | jq -r '.address')" = "0x0" ] || [ -z "$ACTIVE_WINDOW_JSON" ]; then
    notify-send -u critical "Screenshot Error" "No active window focused!"
    exit 1
fi

# 4. Parse coordinates correctly: "X,Y WidthxHeight"
GEOM=$(echo "$ACTIVE_WINDOW_JSON" | jq -r '"\(.at[0]),\(.at[1]) \(.size[0])x\(.size[1])"')

# 5. Capture only that specific geometry layout
grim -g "$GEOM" "$SAVE_PATH"

# 6. Copy to clipboard and toast with thumbnail
if [ -f "$SAVE_PATH" ]; then
    wl-copy < "$SAVE_PATH"
    notify-send -a "screenshot" -i "$SAVE_PATH" -t 3000 "Captured Active Window" "Saved to Screenshots & copied to clipboard"
fi

