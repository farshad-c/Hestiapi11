#!/bin/bash

#Installing recquired files of hestia Pi
cd \
&& sudo rm -rf /home/pi/git \
&& mkdir /home/pi/git \
&& cd /home/pi/git/ \
&& git clone --single-branch --branch ONE https://github.com/HestiaPi/hestia-touch-openhab.git \
&& cd /home/pi/git/hestia-touch-openhab/home/pi/ \
&& cp -R scripts /home/pi/ \
&& cd /home/pi/scripts/ \
&& sudo chmod +x updateone.sh \
&& touch /tmp/publicip \
&& sudo chmod 777 /tmp/publicip \
&& sudo ./updateone.sh;
