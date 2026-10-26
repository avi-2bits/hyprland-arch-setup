#!/bin/bash

# $1 is passed from zathura as $DBUS
TARGET_DBUS="$1"
STATE_FILE="/tmp/zathura_theme_state"

if [ -f "$STATE_FILE" ] && [ "$(cat "$STATE_FILE")" = "dark" ]; then
    # --- SWITCH TO GRUVBOX LIGHT ---
    echo "light" > "$STATE_FILE"
    LIGHT="#fbf1c7"
    DARK="#282828"
    SB_BG="#ebdbb2"
    SB_FG="#3c3836"
else
    # --- SWITCH TO GRUVBOX DARK ---
    echo "dark" > "$STATE_FILE"
    LIGHT="#1d2021"
    DARK="#ebdbb2"
    SB_BG="#282828"
    SB_FG="#a89984"
fi

# Send the settings directly into Zathura via D-Bus
dbus-send --type=method_call --dest="$TARGET_DBUS" /org/pwmt/zathura org.pwmt.zathura.ExecuteCommand string:"set recolor-lightcolor '$LIGHT'"
dbus-send --type=method_call --dest="$TARGET_DBUS" /org/pwmt/zathura org.pwmt.zathura.ExecuteCommand string:"set recolor-darkcolor '$DARK'"
dbus-send --type=method_call --dest="$TARGET_DBUS" /org/pwmt/zathura org.pwmt.zathura.ExecuteCommand string:"set default-bg '$LIGHT'"
dbus-send --type=method_call --dest="$TARGET_DBUS" /org/pwmt/zathura org.pwmt.zathura.ExecuteCommand string:"set default-fg '$DARK'"
dbus-send --type=method_call --dest="$TARGET_DBUS" /org/pwmt/zathura org.pwmt.zathura.ExecuteCommand string:"set statusbar-bg '$SB_BG'"
dbus-send --type=method_call --dest="$TARGET_DBUS" /org/pwmt/zathura org.pwmt.zathura.ExecuteCommand string:"set statusbar-fg '$SB_FG'"
