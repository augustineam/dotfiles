#!/bin/bash

# Define your "Stay Awake" windows (minutes of the hour)
# Example: 10-20 and 40-50
CURRENT_MIN=$(date +%M)

# 1. Check if an SSH session is active
if who | grep -q "(.*)"; then
    echo "SSH session active. Staying awake."
    exit 0
fi

# 2. Check if a tmux session is running (optional)
if pgrep -x "tmux" > /dev/null; then
    echo "Tmux session running. Staying awake."
    exit 0
fi

# 3. Checks if more than 10 packets moved in the last 2 seconds
RX1=$(cat /sys/class/net/nordlynx/statistics/rx_packets)
sleep 2
RX2=$(cat /sys/class/net/nordlynx/statistics/rx_packets)

if [ $((RX2 - RX1)) -gt 10 ]; then
    echo "Meshnet traffic detected. Staying awake."
    exit 0
fi

# 4. Logic to sleep if we are outside the "duty" windows
# This is a simplified version: if we hit the end of our window, sleep for 20m.
if [ "$CURRENT_MIN" -eq 20 ]; then
    echo "End of Window 1. Sleeping for 20 minutes..."
    rtcwake -m mem -s 1200
elif [ "$CURRENT_MIN" -eq 50 ]; then
    echo "End of Window 2. Sleeping for 20 minutes..."
    rtcwake -m mem -s 1200
fi
