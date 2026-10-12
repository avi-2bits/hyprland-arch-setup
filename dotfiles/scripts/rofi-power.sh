#!/usr/bin/env bash
# ~/.local/bin/rofi-power.sh - Optimized Rofi Power Menu

# 1. Define actions with Nerd Font icons
opt_logout="󰗽  Logout"
opt_sleep="󰤄  Suspend"
opt_reboot="󰑐  Reboot"
opt_poweroff="⏻  Power Off"

# 2. Feed options to Rofi using printf
chosen=$(printf "%s\n" \
    "$opt_sleep" \
    "$opt_logout" \
    "$opt_reboot" \
    "$opt_poweroff" | rofi -dmenu -i -p "Power" -no-custom)

# 3. Handle selection
case "$chosen" in
    "$opt_sleep")
        systemctl suspend ;;
    "$opt_logout")
        pkill -u "$USER" -x mango || loginctl terminate-session "${XDG_SESSION_ID:-}" ;;
    "$opt_reboot")
        systemctl reboot ;;
    "$opt_poweroff")
        systemctl poweroff ;;
    *)
        exit 0 ;;
esac

