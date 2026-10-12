#!/usr/bin/env bash
# ~/.config/scripts/powermenu.sh

# Power actions structured to render with icons and titles
lock="🔒  Lock Screen"
suspend="💤  Suspend"
logout="🚪  Log Out"
reboot="🔄  Reboot"
shutdown="🛑  Shut Down"

options="$lock\n$suspend\n$logout\n$reboot\n$shutdown"

# Launches rofi in dmenu mode but utilizing your systems active config rules/theme
chosen=$(echo -e "$options" | rofi -dmenu -i -p "Power Menu")

# Action Router
case "$chosen" in
    "$lock")
        if command -v gtklock &> /dev/null; then
            gtklock
        else
            notify-send -u critical "Lock Error" "gtklock is not installed."
        fi
        ;;
    "$suspend")
        systemctl suspend
        ;;
    "$logout")
        hyprctl dispatch exit ""
        ;;
    "$reboot")
        systemctl reboot
        ;;
    "$shutdown")
        systemctl poweroff
        ;;
    *)
        exit 0
        ;;
esac

