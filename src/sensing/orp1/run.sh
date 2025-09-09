itf="/dev/ttyACM0"
freq=9600
ino_name="orp1"

curr_path=$(dirname "$0")
ino_path="${curr_path}/${ino_name}.ino"

$1 compile --quiet --fqbn arduino:avr:uno "${ino_path}" 
$1 upload --log-level panic -p $itf --fqbn arduino:avr:uno "${ino_path}"

# read output
stty -F $itf $freq raw -clocal -echo
timeout --preserve-status 30s cat $itf | while IFS= read -r line; do
  echo "$(date '+%F %T') | $ino_name | $line"
done
