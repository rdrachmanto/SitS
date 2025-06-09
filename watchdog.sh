#!/bin/bash

# Get the system uptime in seconds
uptime_seconds=$(cut -d. -f1 /proc/uptime)

# Define the threshold for powering off (10 minutes in seconds)
threshold=600


poweroff_pj() {
    python3.7 /home/pi/Documents/deploy/pijuice/wakeup_enable.py
    echo "status before sleep:"
    python3.7 /home/pi/Documents/deploy/pijuice/status.py
    echo "no active ssh, power off ..."
    python3.7 /home/pi/Documents/deploy/pijuice/poweroff.py
}


# Check if the uptime is longer than the threshold
while true; do
    if [ "$uptime_seconds" -gt "$threshold" ]; then
        echo "Uptime is longer than 10 minutes. Powering off..."
        poweroff_pj
        break
    else
        echo "Uptime is still within 10 minutes. Not powering off."
        sleep 10
    fi
done
