#!/bin/bash

# ===========================
# Functions
# ===========================
create_folder() {
  mkdir -p ~/Documents/log
}

create_env() {
  sudo apt install python3-venv
  python3 -m venv ~/Documents/venv_sits --system-site-packages
  source ~/Documents/venv_sits/bin/activate
  pip install numpy pandas
}

prerequisite() {
  sudo apt update
  sudo apt remove -y unattended-upgrades
  sudo locale-gen en_US.UTF-8 en_GB.UTF-8

  wget https://archive.raspberrypi.org/debian/pool/main/r/raspi-config/raspi-config_20211019_all.deb -p ./
  sudo apt -y install libnewt0.52 whiptail parted triggerhappy lua5.1 alsa-utils libraspberrypi-bin wget gcc make unzip
  sudo dpkg -i archive.raspberrypi.org/debian/pool/main/r/raspi-config/raspi-config_20211019_all.deb
  rm /tmp/raspi-config_20211019_all.deb
  rm -r archive.raspberrypi.org

  sudo apt-get install -y vim net-tools tasksel wiringpi i2c-tools fswebcam rfkill wireless-tools raspi-config digitemp python3-venv lua5.3 libraspberrypi-bin
}

setup_arduino() {
  echo "Installing arduino-cli"
  curl -fsSL https://raw.githubusercontent.com/arduino/arduino-cli/master/install.sh | sh
  mv bin/arduino-cli ~/
  ~/arduino-cli core install arduino:avr

  echo "Installing arduino packages ..."
  ~/arduino-cli config init
  ~/arduino-cli config set library.enable_unsafe_install true
  ~/arduino-cli lib install --git-url https://github.com/DFRobot/DFRobot_EC.git
  ~/arduino-cli lib install --git-url https://github.com/DFRobot/DFRobot_EC10.git
  ~/arduino-cli lib install --git-url https://github.com/adafruit/Adafruit_Seesaw.git
  ~/arduino-cli lib install --git-url https://github.com/adafruit/Adafruit_BusIO.git
  #~/arduino-cli lib install --git-url https://github.com/Seeed-Studio/Seeed_SCD30.git
  ~/arduino-cli lib install --git-url https://github.com/DFRobot/DFRobot_SHT20.git

  ~/arduino-cli lib install --git-url https://github.com/milesburton/Arduino-Temperature-Control-Library.git
  ~/arduino-cli lib install --git-url https://github.com/Sensirion/arduino-core.git
  ~/arduino-cli lib install --git-url https://github.com/Sensirion/arduino-i2c-scd4x.git
  ~/arduino-cli lib install --git-url https://github.com/Sensirion/arduino-core.git
  ~/arduino-cli lib install VernierLib

  wget https://github.com/PaulStoffregen/OneWire/archive/v2.3.2.zip
  ~/arduino-cli lib install --zip-path v2.3.2.zip

  rm v2.3.2.zip
  rm -rf bin
}

setup_scd4x() {
  wget https://github.com/Sensirion/raspberry-pi-i2c-scd4x/archive/refs/tags/0.2.2.tar.gz
  tar -zxvf 0.2.2.tar.gz
  cd raspberry-pi-i2c-scd4x-0.2.2/
  make
  cd ..
  rm 0.2.2.tar.gz
}

setup_pijuice() {
  sudo apt install -y i2c-tools lua5.3
  sudo usermod -aG i2c pi
  echo "pi ALL=(pijuice) ALL" | sudo tee -a /etc/sudoers
  echo "dtoverlay=i2c-rtc,ds1339" | sudo tee -a /boot/config.txt
  git clone https://github.com/PiSupply/PiJuice.git
  cd PiJuice/Software/Install
  sudo apt --fix-broken -y install
  sudo apt install -y python3-smbus
  sudo apt install -y pijuice-base

  sudo dpkg -i pijuice-base_1.8_all.deb
  cd ../../..
  rm -r PiJuice

  sudo tee -a /etc/rc.local <<-EOF
  #!/bin/sh -e
  echo ds1339 0x68 > /sys/class/i2c-adapter/i2c-1/new_device
  sudo hwclock -s
  exit 0
  EOF
}


# ===========================
# Steps
# ===========================
prerequisite
setup_arduino
setup_scd4x
setup_pijuice
create_folder
create_env

echo "Please change pijuice rtc pin to 52"
echo "Then reboot"
