
intf="/dev/ttyACM0"
freq=9600

$1 compile --fqbn arduino:avr:uno tm2.ino
$1 upload -p $intf --fqbn arduino:avr:uno tm2.ino
stty -F $intf $freq raw -clocal -echo
cat $intf

