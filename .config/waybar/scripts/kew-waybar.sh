#!/bin/sh

# Check if kew is running and get its status
PLAYER_STATUS=$(playerctl -p kew status 2>/dev/null)

if [ "$PLAYER_STATUS" = "Playing" ]; then
    # Get title and format it as requested
    TITLE=$(playerctl -p kew metadata title | sed 's/&/\\&/g')
    echo "{\"text\": \"$TITLE ::\", \"class\": \"playing\"}"
else
    # Show only the icon if paused or stopped
    echo "{\"text\": \"🎵::\", \"class\": \"paused\"}"
fi
