#!/bin/bash


# python path
pth() {
    /home/pi/Documents/venv_sits/bin/python3 $1
}


## check ssh status
checkSsh() {
    # Run netstat command to get the number of SSH connections
    netstat -an | grep ':22' | grep 'ESTABLISHED'
    ssh_connections=$(netstat -an | grep ':22' | grep 'ESTABLISHED' | wc -l)
    echo "ssh: $ssh_connections"
    # Check the number of SSH connections
    if [ "$ssh_connections" -eq 0 ]; then
        poweroff_pj
    elif [ "$ssh_connections" -eq 1 ]; then
        # Check if "10.*.*.*.:" is present in the connections
        if netstat -an | grep ':22' | grep -q -Eo '\b10\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\b'; then
            echo "active ssh found (1), no poweroff"
        # Check if "*.*.*.1:" is present in the connections
        elif netstat -an | grep ':22' | grep -q -Eo '\b([0-9]{1,3}\.){3}1\b'; then
            poweroff_pj
        else
            echo "active ssh found (1), no poweroff"
        fi
    elif [ "$ssh_connections" -gt 1 ]; then
        echo "active ssh found (>1), no poweroff"
    fi
}


## commit if wifi connected
gitUpdate() {
    if ping -c 1 github.com >/dev/null; then
        echo "GitHub is connected."
        # Add, commit, and push the changes to the repository
        cd /home/pi/Documents/deploy
        git pull
        git commit -m "update "
        git push
    fi
}

## power off if no ssh connected
poweroff_pj() {
    # enable wakeup
    pth /home/pi/SitS/src/pijuice/wakeup_enable.py
    echo "status before sleep:"
    pth /home/pi/SitS/src/pijuice/status.py
    echo "power off ..."
    pth /home/pi/SitS/src/pijuice/poweroff.py
}

## schedule
schedule() {
    # schedule
    pth /home/pi/SitS/src/pijuice/status.py
    pth /home/pi/SitS/src/pijuice/wakeup.py
    pth /home/pi/SitS/src/scheduler/driver.py
    pth /home/pi/SitS/src/pijuice/status.py
}


echo "=====================  scheduling  ========================"
echo "timeUTC: $(/home/pi/Documents/venv_sits/bin/python3 /home/pi/SitS/src/pijuice/time.py)"

# watchdog
#sh watchdog.sh &

# check code update
#gitUpdate

# schedule
schedule

# check code update
#gitUpdate

# check ssh
checkSsh
#for i in {1..15}; do
#  checkSsh
#  sleep 60
#done



#poweroff_pj
