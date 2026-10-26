#!/usr/bin/env bash
SAVE_DIR="$HOME/Pictures/Screenshots"
mkdir -p "$SAVE_DIR"
FILE_NAME="screenshot_$(date +'%Y%m%d_%H%M%S').png"
SAVE_PATH="$SAVE_DIR/$FILE_NAME"

sleep 0.15
grim "$SAVE_PATH"

if [ -f "$SAVE_PATH" ]; then
    wl-copy < "$SAVE_PATH"
    notify-send -a "screenshot" -i "$SAVE_PATH" -t 3000 "Captured Fullscreen" "Saved & copied to clipboard"
fi

