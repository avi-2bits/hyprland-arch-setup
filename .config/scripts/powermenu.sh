#!/usr/bin/env bash
# ~/.config/scripts/powermenu.sh

lock="🔒  Lock Screen"
suspend="💤  Suspend"
logout="🚪  Log Out"
reboot="🔄  Reboot"
shutdown="🛑  Shut Down"

options="$lock\n$suspend\n$logout\n$reboot\n$shutdown"

# -selected-row 0 ensures "Lock Screen" is always highlighted first.
# -no-custom prevents typing random commands.
chosen=$(echo -e "$options" | rofi -dmenu -i -p "Power" -selected-row 0 -no-custom)

case "$chosen" in
    "$lock")
        if command -v gtklock &> /dev/null; then
            gtklock
        else
            notify-send -u critical "Lock Error" "gtklock is not installed."
        fi
        ;;
    "$suspend")
        # Lock cleanly via systemd before suspending to prevent lock-screen bypass
        loginctl lock-session && sleep 0.2
        systemctl suspend
        ;;
    "$logout")
        hyprctl dispatch exit
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

