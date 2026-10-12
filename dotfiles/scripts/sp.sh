#!/usr/bin/env bash
# ~/.config/scripts/sp.sh

SP_DIR="$HOME/.config/scripts/sp"
SUBMAP_ARG="$1"

# ---------------------------------------------------------
# Case A: No arguments -> Generate HUD Menu
# ---------------------------------------------------------
if [ -z "$SUBMAP_ARG" ]; then
    # Clear any old leader popups first
    makoctl dismiss -a 2>/dev/null

    # Build dynamic menu string
    MENU_TEXT=""

    for filepath in "$SP_DIR"/[a-z]_*.sh; do
        [ -f "$filepath" ] && [ -x "$filepath" ] || continue
        filename=$(basename "$filepath")

        hotkey="${filename%%_*}"
        label="${filename#*_}"
        label="${label%.sh}"
        label="${label//-/ }"
        label="${label//_/ }"
        label="$(tr '[:lower:]' '[:upper:]' <<< "${label:0:1}")${label:1}"

        MENU_TEXT+="${hotkey}  ➔  ${label}\n"
    done

    # Show Mako HUD
    notify-send -h string:x-canonical-private-synchronous:leader-mode \
                "LEADER MODE ACTIVE" \
                "$(printf "$MENU_TEXT\n[Press ESC to Cancel]")"

    exit 0
fi

# ---------------------------------------------------------
# Case B: Key argument -> Find and Execute Matching Script
# ---------------------------------------------------------
TARGET_SCRIPT=$(find "$SP_DIR" -maxdepth 1 -name "${SUBMAP_ARG}_*.sh" \( -perm -111 -o -perm -100 \) -print -quit)

# Instantly dismiss the Mako HUD menu
makoctl dismiss -a 2>/dev/null

if [ -n "$TARGET_SCRIPT" ] && [ -f "$TARGET_SCRIPT" ]; then
    # Execute matching action in background
    "$TARGET_SCRIPT" &
fi
