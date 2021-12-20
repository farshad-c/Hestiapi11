#Edit config.txt file
echo 'max_usb_current=1
hdmi_group=2
hdmi_mode=87
hdmi_cvt 800 480 60 6 0 0 0
hdmi_drive=1
dtoverlay=ads7846,penirq=25,speed=10000,penirq_pull=2,xohms=150' | sudo tee --append /boot/config.txt;

#Display calibration
sudo rm -rf /etc/X11/xorg.conf.d/99-calibration.conf;
sudo touch /etc/X11/xorg.conf.d/99-calibration.conf;
echo 'Section "InputClass"
        Identifier      "calibration"
        MatchProduct    "ADS7846 Touchscreen"
        Option  "Calibration"   "3694 232 3827 100"
        Option  "SwapAxes"      "1"
EndSection' | sudo tee /etc/X11/xorg.conf.d/99-calibration.conf;

#reboot
sudo reboot;
