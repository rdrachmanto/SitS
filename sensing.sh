# -----------------------------------------------------
# Variables to use, mainly path
# Try to be as explicit as possible
# -----------------------------------------------------
adn_cli="/home/pi/arduino-cli"
cam_code_path="/home/pi/Documents/deploy/sensors/camera.sh"
img_path="/home/pi/Documents/log/img"
soil_log_file="/home/pi/Documents/log/$(date '+%F_%T')_sensing_soil.log"
air_log_file="/home/pi/Documents/log/$(date '+%F_%T')_sensing_air.log"
sensing_dir="/home/pi/SitS/src/sensing"
sensor_json_loc="/home/pi/SitS/src/sensing/active_sensors.json"

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
  # "tm2"
  # "moi2"
  "ph1"
  "ph2"
  "ec1"
  "ec2"
  # "orp1"
  "orp2"
)

for sr in "${sensors[@]}"; do
  # cd "${curr_folder}/${sr}"

  if [ $sr = "tm1" ]; then
    # Get centigrade temp and change temperature variable of ec2 and ph2
    temp=$(digitemp_DS9097 -n 1 -d 2 -t 0 -q -o "%.2C")
    sed -i "s/temperature = .*/temperature = $temp;/" $sensing_dir/ec2/ec2.ino
    sed -i "s/temperature = .*/temperature = $temp;/" $sensing_dir/ph2/ph2.ino

    # Log centigrade temp
    timeout --preserve-status digitemp_DS9097 -n 0 -d 2 -t 0 -q -o "%.2C" | while IFS= read -r line; do
      echo "$(date '+%F %T'),${sr},${line},${line}"
    done >> "${soil_log_file}"
  else
    # Important variables
    interface=/dev/ttyACM0
    freq=$(jq -r ".${sr}.freq" ${sensor_json_loc})
    timeout=$(jq -r ".${sr}.timeout" ${sensor_json_loc})
    ino_path="${sensing_dir}/${sr}/${sr}.ino"

    # Compile and upload .ino
    ${adn_cli} compile --fqbn arduino:avr:uno "${ino_path}" 
    ${adn_cli} upload -p ${interface} --fqbn arduino:avr:uno "${ino_path}"

    # Log sensor data
    stty -F ${interface} $freq raw -clocal -echo
    timeout --preserve-status ${timeout} cat ${interface} | while IFS= read -r line; do
      [[ "$line" == *"_kvalue"* ]] && continue
      echo "$(date '+%F %T'),${sr},$line"
    done >> "${soil_log_file}"
  fi
done
