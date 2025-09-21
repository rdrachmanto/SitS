= Getting Started with SitS
#v(1em)

== Raspberry Pi Flashing

=== Preparations

1. SD Card
2. SD Card dongle (if needed)
3. Raspberry Pi Imager, available in #link("https://www.raspberrypi.com/software/")

=== Steps
1. Insert SD card to your computer
2. Open Raspberry Pi Imager
3. Select "Raspberry Pi 4" as device
4. Go with `Other general purpose OS -> Ubuntu -> Ubuntu Server 20.04.5 LTS (64-bit)` for the OS to flash
5. Choose the SD card as storage
6. Click Next, and choose `edit settings` when prompted
7. Customize the username, password, WiFi and WiFi password to use. In this doc, we use this set of credentials

  ```
  Raspberry Pi Username: pi
  Raspberry Pi Password: raspberry
  WiFi SSID:      XXXXXXXX 
  WiFi Password:  XXXXXXXX
  ```

8. Still inside the `Edit Settings` pop-up window, go to `Services` tab and check `Enable SSH option` and `Use password authentication`
9. Save the settings
10. Choose `YES` to apply the credentials and settings that was previously edited so it is applied to the Pi when flashed
11. Begin flashing the SD card
12. Put the flashed SD card to the Pi

#v(1em)

== Power up and Connect

The platform can get powered by connecting the raspberry pi the solar panel, or a cable to powerbank or outlet. Once connected, the PiJuice board should start blinking
green-blue or red-blue, depending on charging level.

There are three buttons of PiJuice from left-to-right (left closest to charging indicator led) with these sets of controls:
1. When the leftmost button is pressed once, it will power up the Pi
2. Long press for at least 10 seconds to halt (soft shutdown)
3. Long press for at least 20 seconds to cut power (hard shutdown)

=== Connecting to Pi

Make sure to have a 2.4 GHz Wi-Fi or Wi-Fi hotspot with the same SSID and password set during the flashing step, and connect the PC to the same Wi-Fi

1. Type the following command on your PC to know your IP addresses:

  ```bash
  ifconfig  # (On linux or mac)
  ipconfig  # (On windows)
  ```

2. Look to the output of `wlp0s20f3` or `wlan0`. Note down the IP address after the `inet`. In this case, we note down `192.168.1` and not `192.168.1.66`

  ```bash
  wlp0s20f3: flags=4163<UP,BROADCAST,RUNNING,MULTICAST>  mtu 1500
    inet 192.168.1.166  netmask 255.255.255.0  broadcast 192.168.1.255     
    inet6 fd00:f469:42e7:16b0:3ffc:e464:32e2:9a79  prefixlen 64  scopeid 0x0<global>
    inet6 fe80::e560:148f:3efd:85aa  prefixlen 64  scopeid 0x20<link>
    inet6 2600:6c5a:467f:a919:9854:e351:31e8:e03  prefixlen 64  scopeid 0x0<global>
    inet6 2600:6c5a:467f:a919::137c  prefixlen 128  scopeid 0x0<global>
    inet6 fd00:f469:42e7:16b0::137c  prefixlen 128  scopeid 0x0<global>
    ether 86:01:f9:99:65:38  txqueuelen 1000  (Ethernet)
    RX packets 25793444  bytes 29397825042 (27.3 GiB)
    RX errors 0  dropped 61  overruns 0  frame 0
    TX packets 4934115  bytes 8458738939 (7.8 GiB)
    TX errors 0  dropped 1577 overruns 0  carrier 0  collisions 0
  ```

3. Scan the network

  With the IP Address noted in the step previously, we can use the nmap command figure out the IP address of the Raspberry Pi (as long as it is on, and on the same Wi-Fi). The filter to use is `192.168.1.0/24`

  ```bash
  sudo nmap -sn <FILTER>   # i.e. sudo nmap -sn 192.168.1.0/24
  ```

4. Look for an entry with Raspberry Pi Trading and note down the Pi's IP address

  To connect to the Pi, enter this command, and type the pi's password when prompted. On some OS, there are no characters shown to the terminal when typing the password for security reasons, type the password as normal

  ```sh
  ssh pi@192.168.1.xx
  ```

#v(1em)

== Set up SitS

1. This only has to be done once, if the device is freshly flashed and doesn't have the project yet, type this command

  ```bash
  pi@ubuntu:~$ git clone https://github.com/rdrachmanto/SitS.git
  pi@ubuntu:~$ cd Sits
  pi@ubuntu:~$ bash bootstrap.sh
  ```

2. When the setup is done, check PiJuice's RTC Pin and change it to 52 by going to PiJuice CLI with this command:

  ```bash
  pi@ubuntu:~$ pijuice_cli
  ```

  Then check `General -> RTC Pin` and change the value to 52

#v(1em)

== Ensure Sensor is Connected Correctly

To ensure the sensing platform works, the sensor wires should be connected to the correct port of the Arduino.
Inside `src/sensors/deploy/` directory there is a collection of folders called `ph1` or similar. Go to the `.ino` file inside it, i.e. `ph1.ino`
Around the top of these `.ino` files, there should be a section showing what port should the sensor connect to.
Sensors not meant to be connected to Arduino (and should be connected to the Pi) is labeled with the "pi-" prefix

#v(1em)

== Sensing and Scheduling

To check if all sensors can run properly and the output is saved on the Pi, run the below command:

```bash
pi@ubuntu:~$ sudo bash /home/pi/SitS/sensing.sh
```

=== Turn on Scheduling

To turn on the scheduling function, run:

```bash
pi@ubuntu:~$ sudo bash /home/pi/SitS/main.sh
```

=== Turn off Scheduling

Note: Inside crontab, use HJKL to move the cursor around

```bash
pi@ubuntu:~$ sudo crontab -e
```

Inside the crontab window:

1. Use the HJKL control to move to the start of the script,
2. Press 'i' to enter insert mode, and type "\#" at the start of the line to disable the scheduler on the next boot
3. Press "ESC" to turn back to normal mode
4. Hit "SHIFT+;", then type "wq" or "x" and then press "ENTER"

Next, reboot the Pi with:

```bash
pi@ubuntu:~$ sudo reboot -h now
```

#v(1em)

== Accessing and Downloading Logs

After running `sensing.sh` or `main.sh`, there should be log files available at the below locations on the Pi:

Soil sensors data: `/home/pi/Documents/log/sensing_soil.log`
Air sensors data: `/home/pi/Documents/log/sensing_air.log`
Image data: `/home/pi/Documents/log/img/`
Scheduling data: `/home/pi/SitS/src/scheduler/data/scheduling_log.csv`

To save these log files to the PC, type these commands in a new terminal window:

```bash
scp -r pi@192.168.1.xxx:<LOG FILE LOCATION> <DESTINATION FOLDER ON LOCAL PC>

# For example:
scp -r pi@192.168.1.183:/home/pi/Documents/log/sensing_soil.log Downloads/SensorData
```
