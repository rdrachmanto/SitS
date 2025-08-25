itf="/dev/ttyACM0"
freq=9600
ino_name="ec2.ino"

curr_path=$(dirname "$0")
ino_path="${curr_path}/${ino_name}"
#echo "ino path: ${ino_path}"

$1 compile --fqbn arduino:avr:uno "${ino_path}" 
$1 upload -p $itf --fqbn arduino:avr:uno "${ino_path}"

# read output
#stty -F $itf $freq raw -clocal -echo
#cat $itf



