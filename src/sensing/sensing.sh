adn_cli="/home/pi/arduino-cli"
cam_code_path="/home/pi/Documents/deploy/sensors/camera.sh"
img_path="/home/pi/Documents/log/img"
soil_log_file="/home/pi/Documents/log/sensing_soil.log"
air_log_file="/home/pi/Documents/log/sensing_air.log"
curr_folder="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"

# echo "timeUTC: $(/home/pi/Documents/venv_sits/bin/python3 /home/pi/Sits/src/pijuice/time.py)" >> "${soil_log_file}"

### camera
# echo "image sensor ..."
# bash "${cam_code_path}"  "${img_path}"
#
# echo "read air sensors ..."
# echo "timeUTC: $(/home/pi/Documents/venv_sits/bin/python3 /home/pi/Sits/src/pijuice/time.py)" >> "${air_log_file}"
# timeout --preserve-status 62s /home/pi/Documents/deploy/sensors/air_sensor "${air_log_file}" &


echo "compile arduino ..."
echo "read arduino sensors ..."

sensors=(
  "tm1"
  "tm2"
  "moi2"
  "ph1"
  "ph2"
  "ec1"
  "ec2"
  "orp1"
  "orp2"
)

for sr in "${sensors[@]}"; do
  cd "${curr_folder}/${sr}"
  # bash run.sh "${adn_cli}" >> "${soil_log_file}"

  if [ sr = "tm1" ]; then
    # Get centigrade temp and change temperature variable of ec2 and ph2
    temp=$(digitemp_DS9097 -n 1 -d 2 -t 0 -q -o "%.2C")
    sed -i "s/temperature = .*/temperature = $temp;/" ../ec2/ec2.ino
    sed -i "s/temperature = .*/temperature = $temp;/" ../ph2/ph2.ino

    # Log centigrade temp
    timeout --preserve-status digitemp_DS9097 -n 0 -d 2 -t 0 -q -o "%.2C" | while IFS= read -r line; do
      echo "$(date '+%F %T'),${sr},${line},${line}"
    done >> "${soil_log_file}"
  else
    # Important variables
    interface=/dev/ttyACM0
    freq=$(jq ".${sr}.freq" ./active_sensors.json)
    timeout=$(jq ".${sr}.timeout" ./active_sensors.json)
    curr_path=$(dirname "$0")
    ino_path="${curr_path}/${sr}.ino"

    # Compile and upload .ino
    ${adn_cli} compile --fqbn arduino:avr:uno "${ino_path}" 
    ${adn_cli} upload panic -p ${interface} --fqbn arduino:avr:uno "${ino_path}"

    # Log sensor data
    stty -F ${interface} $freq raw -clocal -echo
    timeout --preserve-status ${timeout} cat ${interface} | while IFS= read -r line; do
      echo "$(date '+%F %T'),${sr},$line"
    done >> "${soil_log_file}"
  fi
done
