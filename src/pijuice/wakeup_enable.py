#!/usr/bin/python3
# This script is started at reboot by cron
# Since the start is very early in the boot sequence we wait for the i2c-1 device

import time, os
from Pijuice import Pijuice


while not os.path.exists('/dev/i2c-1'):
    time.sleep(0.1)

pj = Pijuice().pj
pj.rtcAlarm.SetWakeupEnabled(True)