#!/usr/bin/env bash
# ~/.config/hypr/swaybg.sh
STATE_FILE="$HOME/.config/hypr/.wallpaper_state"
DEFAULT_DIR="$HOME/Pictures/wall"

mkdir -p "$DEFAULT_DIR"

if [ -n "$1" ]; then
    IMAGE_PATH=$(realpath "$1")
    echo "FILE:$IMAGE_PATH" > "$STATE_FILE"
elif [ -f "$STATE_FILE" ]; then
    ENTRY=$(cat "$STATE_FILE")
    MODE="${ENTRY%%:*}"
    TARGET="${ENTRY#*:}"

    if [ "$MODE" = "DIR" ] && [ -d "$TARGET" ]; then
        IMAGE_PATH=$(find "$TARGET" -maxdepth 1 -type f \( -iname "*.jpg" -o -iname "*.png" -o -iname "*.webp" \) | shuf -n1)
    elif [ "$MODE" = "FILE" ] && [ -f "$TARGET" ]; then
        IMAGE_PATH="$TARGET"
    fi
fi

[ -z "$IMAGE_PATH" ] && IMAGE_PATH=$(find "$DEFAULT_DIR" -maxdepth 1 -type f \( -iname "*.jpg" -o -iname "*.png" -o -iname "*.webp" \) | shuf -n1)
[ -z "$IMAGE_PATH" ] && exit 0

swaybg -m fill -i "$IMAGE_PATH" >/dev/null 2>&1 &
NEW_PID=$!
sleep 0.05
pgrep swaybg | grep -v "$NEW_PID" | xargs -r kill 2>/dev/null
disown

