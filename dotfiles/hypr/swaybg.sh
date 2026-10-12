#!/usr/bin/env bash

STATE_FILE="$HOME/.config/hypr/.swaybg"
IMAGE_PATH="$1"

# 1. Restore mode if no argument passed
if [ -z "$IMAGE_PATH" ]; then
    if [ -f "$STATE_FILE" ]; then
        IMAGE_PATH=$(cat "$STATE_FILE")
    else
        echo "No wallpaper state found. Pass an image path."
        exit 1
    fi
else
    # Convert relative path to absolute
    IMAGE_PATH=$(realpath "$IMAGE_PATH")
fi

# Ensure the image actually exists
if [ ! -f "$IMAGE_PATH" ]; then
    echo "Error: File '$IMAGE_PATH' does not exist."
    exit 1
fi

# 2. Save state
echo "$IMAGE_PATH" > "$STATE_FILE"

# 3. Kill OLD instances FIRST
killall -q swaybg

# 4. Spawn the NEW instance and detach it completely so it lives
swaybg -m fill -i "$IMAGE_PATH" >/dev/null 2>&1 &
disown

