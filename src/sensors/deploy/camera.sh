#!/bin/bash


TakePic () {
    for i in {0..5..1}; do
        checkCam=$(ls /dev | grep video0 | wc -l)
        echo "checkCam $i th: $checkCam"
        [ $checkCam -ne 0 ] && break || sleep 1
    done
    [ ! -d "$1/" ] && mkdir -p "$1/"
    fileName="$(/home/pi/Documents/venv_sits/bin/python3 /home/pi/Documents/deploy/pijuice/time.py).jpg"
    storePath="$1/$fileName"
    v4l2-ctl --set-ctrl=exposure_auto=2
    v4l2-ctl --set-ctrl=focus_auto=1
    fswebcam -r 1280x720 --delay 3 --skip 20 --set "Focus, Auto=1" --frames 15 --jpeg 50 --no-banner $storePath
    #Log "$fileName"
}



### Main ###

TakePic $1


