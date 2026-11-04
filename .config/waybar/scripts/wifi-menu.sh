#!/usr/bin/env bash
# Minimal, lightning-fast Wi-Fi selector using fuzzel
# Zero background RAM.

# Get list of SSIDs
SSIDS=$(nmcli --fields SSID,SECURITY dev wifi list | tail -n +2 | grep -v '^--')

# Prompt user
CHOSEN=$(echo -e "Toggle Wi-Fi\n$SSIDS" | fuzzel -d -p "󰖩  WIFI: ")

if [[ "$CHOSEN" == "Toggle Wi-Fi" ]]; then
    STATUS=$(nmcli -fields WIFI r)
    if [[ "$STATUS" =~ "enabled" ]]; then
        nmcli r wifi off
    else
        nmcli r wifi on
    fi
elif [[ -n "$CHOSEN" ]]; then
    SSID=$(echo "$CHOSEN" | awk '{print $1}')
    SEC=$(echo "$CHOSEN" | awk '{print $2}')
    if [[ "$SEC" != "--" ]]; then
        PASS=$(fuzzel -d -p "Password for $SSID: ")
        nmcli dev wifi connect "$SSID" password "$PASS"
    else
        nmcli dev wifi connect "$SSID"
    fi
fi

