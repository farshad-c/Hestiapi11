#!/bin/bash

#edit visudo
echo 'pi ALL=(ALL) NOPASSWD: ALL
openhab ALL=(ALL) NOPASSWD: ALL' | sudo tee --append /etc/sudoers;

#edit bashrc
sudo sed -i 's/HISTCONTROL=ignoreboth/HISTCONTROL=ignoredups/' ~/.bashrc;   #This command is used to prevent the storage of repetitive commands that we use frequently and consecutively. ie, it will store one command at once instead of multiple times when we use it consecutively

#installing the required packages
#sudo apt-get install -y --no-install-recommends xserver-xorg x11-xserver-utils xinit openbox;
#sudo apt-get install -y apt-transport-https bc dnsmasq hostapd vim python3-flask python3-requests dirmngr accountsservice build-essential python quilt devscripts python-setuptools python3 libssl-dev cmake libc-ares-dev uuid-dev daemon zip zlibc zlib1g zlib1g-dev python3-smbus unclutter matchbox-window-manager xwit xinit lxterminal geoclue-2.0 lightdm
cd \
sudo apt-get install -y apt-transport-https bc dnsmasq hostapd vim python3-flask;
sudo apt-get install -y python3-requests dirmngr accountsservice build-essential python quilt;
sudo apt-get install -y devscripts python-setuptools python3 libssl-dev cmake libc-ares-dev;
sudo apt-get install -y uuid-dev daemon zip zlibc zlib1g zlib1g-dev python3-smbus unclutter;
sudo apt-get install -y matchbox-window-manager xwit xinit;
sudo apt-get install -y lxterminal geoclue-2.0;
sudo apt-get install -y --no-install-recommends xserver-xorg;
sudo apt-get install -y --no-install-recommends x11-xserver-utils xinit openbox;

#Create a file .xinitrc
touch /home/pi/.xinitrc \
&& chmod 755 /home/pi/.xinitrc \
&& echo '#!/bin/sh
exec openbox-session' | tee --append /home/pi/.xinitrc;   #xinitrc file is a shell script read by xinit and startx. It is mainly used to execute desktop environments, window managers, and other programs when starting the X server

#confirm this is selected
echo -ne '\n' | sudo update-alternatives --config x-window-manager;
# * 0 /usr/bin/openbox 90 auto mode
sudo update-alternatives --config x-session-manager;
#Confirm there is only one alternative.

#Make WiFi reconnect on drop
sudo cp /etc/wpa_supplicant/ifupdown.sh /etc/ifplugd/action.d/ifupdown

#remove Mosquitto if any
sudo apt-get remove mosquitto -y;

#Install libwebsockets of version 2.4.1 using commands :
cd \
&& wget https://github.com/warmcat/libwebsockets/archive/v2.4.1.zip \
&& unzip v2.4.1.zip \
&& cd libwebsockets-2.4.1/ \
&& mkdir build \
&& cd build \
&& cmake .. \
&& sudo make install \
&& sudo ldconfig;

#Install mosquitto with version 1.4.9
cd \
&& wget http://mosquitto.org/files/source/mosquitto-1.4.9.tar.gz \
&& tar zxvf mosquitto-1.4.9.tar.gz \
&& cd mosquitto-1.4.9 \
&& sed -i -e "s/WITH_WEBSOCKETS:=no/WITH_WEBSOCKETS:=yes/g" config.mk \
&& make \
&& sudo make install \
&& sudo cp mosquitto.conf /etc/mosquitto;

#Input some command lines such as user, port, etc. to mosquitto.conf
echo 'user pi
port 1883
listener 9001
protocol websockets
pid_file /var/run/mosquitto.pid' | sudo tee --append /etc/mosquitto/mosquitto.conf;

#Mosquitto broker does not use the modern system for the startup. To move the old init system, follow the procedure below :
sudo systemctl stop mosquitto;
sudo update-rc.d mosquitto remove;
sudo rm /etc/init.d/mosquitto;

#Input the following content into mosquitto.service
echo '[Unit]
Description=MQTT v3.1 message broker
After=network.target
Requires=network.target

[Service]
Type=simple
ExecStart=/usr/local/sbin/mosquitto -c /etc/mosquitto/mosquitto.conf
Restart=always

[Install]
WantedBy=multi-user.target' | sudo tee --append /etc/systemd/system/mosquitto.service;

sudo systemctl daemon-reload;   #Reload system configuration
sudo systemctl enable mosquitto;    #Enable Mosquitto service to start at boot
sudo systemctl start mosquitto.service;   #Starting Mosquitto service
#Remove libwebsockets, mosquitto downloaded and build files
sudo rm -rf /home/mosquitto /home/pi/.cmake /home/pi/libwebsockets-2.4.1 /home/pi/mosquitto-1.4.9 /home/pi/mosquitto-1.4.9.tar.gz /home/pi/v2.4.1.zip;

#Install Zulu embedded
sudo mkdir /opt/jdk/ \
&& cd /opt/jdk \
&& sudo wget https://cdn.azul.com/zulu-embedded/bin/zulu8.40.0.178-ca-jdk1.8.0_222-linux_aarch32hf.tar.gz \
&& sudo tar -xzvf zulu8.40.0.178-ca-jdk1.8.0_222-linux_aarch32hf.tar.gz \
&& sudo update-alternatives --install /usr/bin/java java /opt/jdk/zulu8.40.0.178-ca-jdk1.8.0_222-linux_aarch32hf/bin/java 8 \
&& sudo update-alternatives --install /usr/bin/javac javac /opt/jdk/zulu8.40.0.178-ca-jdk1.8.0_222-linux_aarch32hf/bin/javac 8 \
&& sudo rm zulu8.40.0.178-ca-jdk1.8.0_222-linux_aarch32hf.tar.gz;

#Confirm there is only one alternative
sudo update-alternatives --config java;
sudo update-alternatives --config javac;

#install openhab2
wget -qO - 'https://openhab.jfrog.io/artifactory/api/gpg/key/public' | sudo apt-key add -
sudo apt-get install apt-transport-https;
echo 'deb https://openhab.jfrog.io/artifactory/openhab-linuxpkg stable main' | sudo tee /etc/apt/sources.list.d/openhab.list;   #Add the openHAB stable repository to your systems apt sources list.
#Check for update and install openHAB and addons package
sudo apt-get update \
&& sudo apt-get install openhab2 \
&& sudo apt-get install openhab2-addons;

#Remove the unwanted files, enabling openhab2.service and add user for I2C and GPIO
sudo apt-get autoremove -y \
&& sudo /bin/systemctl daemon-reload \
&& sudo /bin/systemctl enable openhab2.service \
&& sudo adduser openhab i2c \
&& sudo adduser openhab gpio \
&& sudo reboot;







