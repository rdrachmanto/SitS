#!/bin/bash
ino_name="tm1"

# Input to log file
timeout --preserve-status 10s digitemp_DS9097 -n 0 -d 2 -t 0 -q -o "%.2C" | while IFS= read -r line; do
  # echo "$(date '+%F %T') | $ino_name | $line"
  echo "$(date '+%F %T'),${ino_name},${line},${line}"
done

# Change temp-dependent sensors with readings from this sensor
temp=$(digitemp_DS9097 -n 1 -d 2 -t 0 -q -o "%.2C")
sed -i "s/temperature = .*/temperature = $temp;/" ../ec2/ec2.ino
sed -i "s/temperature = .*/temperature = $temp;/" ../ph2/ph2.ino
