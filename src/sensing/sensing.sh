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
  bash run.sh "${adn_cli}" >> "${soil_log_file}"
done
