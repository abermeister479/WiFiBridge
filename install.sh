#!/usr/bin/env bash

read -p "This will overwrite rc.local and ruin your networking setup. Press enter to continue (or CTRL-C to quit now)"
cd /
git clone https://github.com/escitalopram/wlan_kabel
cd wlan_kabel
make
read -p "What is the MAC address of the client (behind the bridge)? " MAC
echo "#!/usr/bin/env bash
echo \"wlan_kabel starting...\"
/wlan_kabel/wlan_kabel wlan0 eth0 $MAC" > start.sh
echo "#!/usr/bin/env bash
until /wlan_kabel/start.sh; do
	echo \"wlan_kabel crashed with exit code $?. Restarting...\" >&2
	sleep 1
done" > packets.sh
chown root packets.sh start.sh
chmod a-w packets.sh start.sh
chmod u+rwx packets.sh start.sh
echo "#!/bin/sh -e
echo \"Starting wlan_kabel\\n\"
echo \"Boot\\n\" > /wlan_kabel/log
/wlan_kabel/packets.sh &>> /wlan_kabel/log &
exit 0" > /etc/rc.local
echo "auto lo
iface lo inet loopback
auto eth0
iface eth0 inet manual
auto wlan0
iface wlan0 inet manual
	wpa-conf /etc/wpa_supplicant/wpa_supplicant.conf" > /etc/network/interfaces
read -p "What is the SSID of the network? " SSID
read -s -p "What is the password of the network? " PSK
echo "country=US
network={
	ssid=\"$SSID\"
	psk=\"$PSK\"
}" > /etc/wpa_supplicant/wpa_supplicant.conf
echo "Rebooting..."
sleep 1
reboot
