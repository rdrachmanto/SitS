#show link: underline
#show link: set text(fill: blue)
#show table.cell.where(y: 0): set text(weight: "bold")
#show raw.where(block: true): block.with(fill: luma(240), inset: 5pt, width: 100%, radius: 2pt)

= Sensor Calibration
#v(1em)

== Sensor Details
This table details the properties we record in this platform, along with its sensor name in this repository
and if it needs (or possible) to be calibrated

#table(
  columns: (auto, auto, auto),
  table.header("Soil Property", "Sensor Name", "Need to Calibrate"),
  "pH", "ph1", "YES",
  "pH", "ph2", "YES",
  "EC", "ec1", "YES",
  "EC", "ec2", "YES",
  "ORP", "orp1", "NO",
  "ORP", "orp2", "NO",
  "Moisture", "moi2", "NO",
  "Temperature", "tm1", "NO",
)

#pagebreak()

== How to Calibrate

*Preparations*

1. Open two SSH connections to the Pi
2. In one SSH connection, change your directory to the appropriate one by doing:
    ```bash
    pi@ubuntu:~$ cd <Location of SitS project>/src/sensing 
    ```
   Your Pi prompt should change to something similar:
    ```bash
    pi@ubuntu:~/SitS/src/sensing$ 
    ```
3. Just log in to the Pi for the second SSH connection, more details will be shared later on each sensor's steps.
4. Appropriate test solutions:
    - pH 4, pH 7, pH 10
    - EC solution with 12.880, 150000
    - ORP solution of 100 mV and 256 mV

Your terminal connections would look like this:

#pagebreak()

=== PH1

1. In the first connection, type this command to set the Pi to compile and upload PH1's sensor code to Arduino: 
    ```bash 
    pi@ubuntu:~/SitS/src/sensing$ bash run ph1/run.sh
    ```
2. After a while, you will start to see the sensor reading of PH1 in the first connection terminal
3. Start putting in the sensor probe to the test solution, beginning with pH 4
4. In the second SSH terminal, type the command:
    ```bash 
    pi@ubuntu:~$ echo "cal,4,low" > /dev/ttyACM0
    ```
5. After a few seconds, you should see and *\*OK\** message from the first SSH terminal, and notice your sensor readings of pH 4 test solution would change 
6. Repeat Step *\#4 - \#5* with pH 7, and pH 10, with this command:
    ```bash 
    pi@ubuntu:~$ echo "cal,7,mid" > /dev/ttyACM0
    pi@ubuntu:~$ echo "cal,10,high" > /dev/ttyACM0
    ```

Original calibration guide can be seen here: #link("https://how2electronics.com/interfacing-atlas-scientific-ph-sensor-with-arduino-via-uart-i2c/")
#v(1em)

=== PH2 

1. In the first connection, type this command to set the Pi to compile and upload PH2's sensor code to Arduino: 
    ```bash 
    pi@ubuntu:~/SitS/src/sensing$ bash run ph2/run.sh
    ```
2. After a while, you will start to see the sensor reading of PH2 in the first connection terminal

Original calibration guide can be found here: #link("https://wiki.dfrobot.com/gravity__analog_ph_sensor_meter_kit_v2_sku_sen0161-v2")
#v(1em)

=== EC1 

For EC1, we are going to do a 3-step calibration, first with dry, then 12.880 solution, finished with 150.000 solution

1. In the first connection, type this command to set the Pi to compile and upload EC1's sensor code to Arduino: 
    ```bash 
    pi@ubuntu:~/SitS/src/sensing$ bash run ec1/run.sh
    ```
2. After a while, you will start to see the sensor reading of EC1 in the first connection terminal
3. Do a dry calibration in the second SSH terminal, with the command:
    ```bash 
    pi@ubuntu:~$ echo "cal,dry" > /dev/ttyACM0
    ```
4. After a few seconds, you should see and *\*OK\** message from the first SSH terminal 
5. Put the sensor probe into the first solution, 12.880
6. Do the "low-point" calibration with this command in the second SSH terminal:
    ```bash 
    pi@ubuntu:~$ echo "cal,low,12880" > /dev/ttyACM0
    ```
7. You should see an *\*OK\** message from the first terminal, continue with the "high point" calibration with 150.000 test solution by repeating Step *\#5 - \#6*, changing the command to:
    ```bash 
    pi@ubuntu:~$ echo "cal,high,150000" > /dev/ttyACM0
    ```

Original calibration guide can be found here: #link("https://files.atlas-scientific.com/EC_EZO_Datasheet.pdf")
#v(1em)

=== EC2 

1. In the first connection, type this command to set the Pi to compile and upload EC2's sensor code to Arduino: 
    ```bash 
    pi@ubuntu:~/SitS/src/sensing$ bash run ec2/run.sh
    ```
    #v(0.7em)
2. After a while, you will start to see the sensor reading of EC2 in the first connection terminal

Original calibration guide can be found here: #link("https://wiki.dfrobot.com/Gravity__Analog_Electrical_Conductivity_Sensor___Meter_V2__K=1__SKU_DFR0300")
#v(1em)

=== Other Sensors (ORP, Moisture, Temperature)

While you cannot calibrate these sensors, you can still see the readings of these sensors with this command:

```bash 
pi@ubuntu:~/SitS/src/sensing$ bash run orp1/run.sh
pi@ubuntu:~/SitS/src/sensing$ bash run orp2/run.sh
pi@ubuntu:~/SitS/src/sensing$ bash run moi2/run.sh
pi@ubuntu:~/SitS/src/sensing$ bash run tm1/run.sh
```

Note: 
1. ORP sensor probe needs to be put in a test solution (100 mV, 256 mV for example)
2. Moisture sensor (moi2) and temperature sensor (tm1) can be tested dry or submerged

