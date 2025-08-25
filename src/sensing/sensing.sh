#####################################################
###  ins:  <arduino-cli> <driver sh> <adn foler>  ###
###  e.g.: ~/arduino-cli sensing.sh arduino1      ###
#####################################################

# adn1_folder="tm2"
# adn1_file="tm2.sh"
# adn2_folder="ph1"
# adn2_file="ph1.sh"
# adn3_folder="ec2"
# adn3_file="ec2.sh"
# adn4_folder="orp2"
# adn4_file="orp2.sh"
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

# cd "${curr_folder}/${adn1_folder}"
# bash "${adn1_file}" "${adn_cli}" >> "${soil_log_file}"
# stty -F /dev/ttyACM0 9600 raw -clocal -echo
# timeout --preserve-status 30s cat /dev/ttyACM0 >>  "${soil_log_file}"
#
#
# cd "${curr_folder}/${adn2_folder}"
# bash "${adn2_file}" "${adn_cli}" >> "${soil_log_file}"
# stty -F /dev/ttyACM0 9600 raw -clocal -echo
# timeout --preserve-status 30s cat /dev/ttyACM0 >>  "${soil_log_file}"
#
# cd "${curr_folder}/${adn3_folder}"
# bash "${adn3_file}" "${adn_cli}" >> "${soil_log_file}"
# stty -F /dev/ttyACM0 9600 raw -clocal -echo
# timeout --preserve-status 30s cat /dev/ttyACM0 >>  "${soil_log_file}"
#
# cd "${curr_folder}/${adn4_folder}"
# bash "${adn4_file}" "${adn_cli}" >> "${soil_log_file}"
# stty -F /dev/ttyACM0 9600 raw -clocal -echo
# timeout --preserve-status 30s cat /dev/ttyACM0 >>  "${soil_log_file}"
#

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
  cd "${curr_folder}/${adn4_folder}"
  bash "${adn4_file}" "${adn_cli}" >> "${soil_log_file}"
done
