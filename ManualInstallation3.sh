cd \
&& sudo rm -rf /home/pi/git;

#Install nodeJs Package
wget https://nodejs.org/dist/v8.9.4/node-v8.9.4-linux-armv6l.tar.xz \
&& sudo mkdir /usr/lib/nodejs \
&& sudo tar -xJvf node-v8.9.4-linux-armv6l.tar.xz -C /usr/lib/nodejs \
&& rm -rf node-v8.9.4-linux-armv6l.tar.xz \
&& sudo mv /usr/lib/nodejs/node-v8.9.4-linux-armv6l /usr/lib/nodejs/node-v8.9.4 \
&& echo 'export NODEJS_HOME=/usr/lib/nodejs/node-v8.9.4' >> ~/.profile \
&& echo 'export PATH=$NODEJS_HOME/bin:$PATH' >> ~/.profile \
&& source ~/.profile;

#Install GO
wget https://dl.google.com/go/go1.10.linux-armv6l.tar.gz \
&& sudo tar -C /usr/local -xzf go*gz \
&& rm go*gz \
&& echo 'export PATH=$PATH:/usr/local/go/bin:$HOME/go/bin' >>  ~/.profile \
&& echo 'export GOPATH=$HOME/go' >>  ~/.profile \
&& source ~/.profile;

#Install raspberry-pi-turnkey.git files
cd /home/pi/scripts;
git clone https://github.com/schollz/raspberry-pi-turnkey.git;

#Stop the dnsmasq and hostapd
sudo systemctl stop dnsmasq && sudo systemctl stop hostapd;

#Input static IP commands to dhcpcd.conf
echo 'interface wlan0
static ip_address=192.168.4.1/24' | sudo tee --append /etc/dhcpcd.conf;

#Rename dnsmasq.conf to dnsmasq.conf.orig
sudo mv /etc/dnsmasq.conf /etc/dnsmasq.conf.orig;

#Restart dhcpcd
sudo systemctl daemon-reload \
&& sudo systemctl restart dhcpcd;

#Input dhcp range into the file dnsmasq.conf
echo 'interface=wlan0
dhcp-range=192.168.4.2,192.168.4.20,255.255.255.0,24h' | sudo tee --append /etc/dnsmasq.conf;

#Configure hostapd.conf
echo 'interface=wlan0
driver=nl80211
ssid=HESTIAPI
hw_mode=g
channel=7
wmm_enabled=0
macaddr_acl=0
auth_algs=1
ignore_broadcast_ssid=0
wpa=2
wpa_passphrase=HESTIAPI
wpa_key_mgmt=WPA-PSK
wpa_pairwise=TKIP
rsn_pairwise=CCMP' | sudo tee --append /etc/hostapd/hostapd.conf;

#Reference to it in /etc/default/hostapd
echo 'DAEMON_CONF="/etc/hostapd/hostapd.conf"' | sudo tee --append /etc/default/hostapd;

#Unmask
sudo systemctl unmask hostapd;

#Enable and start the hostapd
sudo systemctl enable hostapd \
&& sudo systemctl start hostapd && sudo systemctl start dnsmasq;

#Change email type = "hidden"
sudo sed -i 's/type="email"/type="hidden"/g' /home/pi/scripts/raspberry-pi-turnkey/templates/index.html;

#Hide a Jessie bug of turnkey
sed '/while checkwpa:/,/^\s*$/d' /home/pi/scripts/raspberry-pi-turnkey/startup.py | sudo tee /home/pi/scripts/raspberry-pi-turnkey/startup.py;
sudo cp ~/manual/test/replace.txt /home/pi/scripts/raspberry-pi-turnkey;
sudo sed -i '/checkwpa = True/r replace.txt' /home/pi/scripts/raspberry-pi-turnkey/startup.py;
sudo rm /home/pi/scripts/raspberry-pi-turnkey/replace.txt;

#chromium web installation
sudo apt-get install chromium-browser

#Remove if any saved Wi-Fi network configuration
sudo sed '/network={/,/^\s*$/d' /etc/wpa_supplicant/wpa_supplicant.conf | sudo tee /etc/wpa_supplicant/wpa_supplicant.conf;

#Setting up Autostart file
cd \
&& sudo sed -i 's/exit 0//g' /etc/rc.local \
&& echo "su pi -c '/usr/bin/sudo /usr/bin/python3 /home/pi/scripts/raspberry-pi-turnkey/startup.py &'
su -l pi -c 'sudo xinit /home/pi/scripts/kiosk-xinit.sh'
exit 0" | sudo tee --append /etc/rc.local;

#reboot
sudo reboot;








