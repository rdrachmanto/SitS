itf="/dev/ttyACM0"
freq=9600
ino_name="ec1"

curr_path=$(dirname "$0")
echo $curr_path
ino_path="${curr_path}/${ino_name}.ino"

$1 compile --fqbn arduino:avr:uno "${ino_path}" 
$1 upload -p $itf --fqbn arduino:avr:uno "${ino_path}"

# read output
stty -F $itf $freq raw -clocal -echo
timeout --preserve-status 30s cat $itf | while IFS= read -r line; do
  echo "$(date '+%F %T') | $ino_name | $line"
done
