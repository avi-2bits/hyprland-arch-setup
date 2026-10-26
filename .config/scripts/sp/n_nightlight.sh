#!/usr/bin/env bash

# Check if wlsunset is running
if pgrep -x "wlsunset" > /dev/null; then
    # If running, kill it to restore default screen colors
    pkill -x "wlsunset"
else
    # trick wlsunset by setting high temp (4001) slightly higher than low temp (4000)
    wlsunset -t 5200 -T 5201 &
fi

