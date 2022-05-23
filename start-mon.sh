#!/bin/bash

SCRIPT_NAME="start-mon.sh"
SCRIPT_VERSION="20220408"


# Purpose: Start and configure monitor mode on the provided interface

# Usage: $ sudo ./start-mon.sh [interface:wlan0]


clear


# Check that sudo was used to start the script
if [[ $EUID -ne 0 ]]
then
	echo
	echo " ERROR: You must run this script with superuser (root) privileges."
	echo -e " Try: sudo ./${SCRIPT_NAME} [interface:wlan0]"
	echo
	exit 1
fi


# Add code to check if iw and ip are installed


# Ensure WiFi radio is not blocked
sudo rfkill unblock wlan


# Assign default monitor mode interface name
iface0mon='wlan0mon'


# Assign default channel
chan=6


# Activate option to set automatic (1) or manual (2) interface mode
#
# Option 1: if you only have one wlan interface (automatic detection)
#iface0=`iw dev | grep 'Interface' | sed 's/Interface //'`
#
# Option 2: if you have more than one wlan interface (default wlan0)
iface0=${1:-wlan0}


# Set iface0 down
ip link set dev $iface0 down
# Check if iface0 exists and continue if true
if [ $? -eq 0 ]
then
#	Disable interfering processes
	PROCESSES="wpa_action\|wpa_supplicant\|wpa_cli\|dhclient\|ifplugd\|dhcdbd\|dhcpcd\|udhcpc\|NetworkManager\|knetworkmanager\|avahi-autoipd\|avahi-daemon\|wlassistant\|wifibox\|net_applet\|wicd-daemon\|wicd-client\|iwd"
	unset match
	match="$(ps -A -o comm= | grep ${PROCESSES} | grep -v grep | wc -l)"
	badProcs=$(ps -A -o pid=PID -o comm=Name | grep "${PROCESSES}\|PID")
	for pid in $(ps -A -o pid= -o comm= | grep ${PROCESSES} | awk '{print $1}'); do
		command kill -19 "${pid}"   # -19 = STOP
	done
	clear
	echo
	echo ' The following processes have been stopped:'
	echo
	echo "${badProcs}"
	echo
	echo ' Note: The above processes can be returned'
	echo ' to a normal state at the end of this script.'
	echo
	read -p " Press any key to continue... " -n 1 -r
	

#	Display interface settings
	clear
	echo
	echo ' --------------------------------'
	echo -e "    ${SCRIPT_NAME} ${SCRIPT_VERSION}"
	echo ' --------------------------------'
	echo '    WiFi Interface:'
	echo '             '$iface0
	echo ' --------------------------------'
	iface_name=$(iw dev $iface0 info | grep 'Interface' | sed 's/Interface //' | sed -e 's/^[ \t]*//')
	echo '    name  - ' $iface_name
	iface_type=$(iw dev $iface0 info | grep 'type' | sed 's/type //' | sed -e 's/^[ \t]*//')
	echo '    type  - ' $iface_type
	iface_state=$(ip addr show $iface0 | grep 'state' | sed 's/.*state \([^ ]*\)[ ]*.*/\1/')
	echo '    state - ' $iface_state
	iface_addr=$(iw dev $iface0 info | grep 'addr' | sed 's/addr //' | sed -e 's/^[ \t]*//')
	echo '    addr  - ' $iface_addr
	echo ' --------------------------------'
	echo


#	Set addr (has to be done before renaming the interface)
	iface_addr_orig=$iface_addr
	read -p " Do you want to set a new addr? [y/N] " -n 1 -r
	echo
	if [[ $REPLY =~ ^[Yy]$ ]]
	then
		read -p " What addr do you want? ( e.g. 12:34:56:78:90:ab ) " iface_addr
#		need code to ID bad addresses
		ip link set dev $iface0 address $iface_addr
	fi


#	Set monitor mode
#	iw dev <devname> set monitor <flag>
#		Valid monitor flags are:
#		none:     no special flags
#		fcsfail:  show frames with FCS errors
#		control:  show control frames
#		otherbss: show frames from other BSSes
#		cook:     use cooked mode
#		active:   use active mode (ACK incoming unicast packets)
#		mumimo-groupid <GROUP_ID>: use MUMIMO according to a group id
#		mumimo-follow-mac <MAC_ADDRESS>: use MUMIMO according to a MAC address
	iw dev $iface0 set monitor none


#	Rename interface
	ip link set dev $iface0 name $iface0mon


#	Bring the interface up
	ip link set dev $iface0mon up
	

#	Display interface settings
	clear
	echo
	echo ' --------------------------------'
	echo -e "    ${SCRIPT_NAME} ${SCRIPT_VERSION}"
	echo ' --------------------------------'
	echo '    WiFi Interface:'
	echo '             '$iface0
	echo ' --------------------------------'
	iface_name=$(iw dev $iface0mon info | grep 'Interface' | sed 's/Interface //' | sed -e 's/^[ \t]*//')
	echo '    name  - ' $iface_name
	iface_type=$(iw dev $iface0mon info | grep 'type' | sed 's/type //' | sed -e 's/^[ \t]*//')
	echo '    type  - ' $iface_type
	iface_state=$(ip addr show $iface0mon | grep 'state' | sed 's/.*state \([^ ]*\)[ ]*.*/\1/')
	echo '    state - ' $iface_state
	iface_addr=$(iw dev $iface0mon info | grep 'addr' | sed 's/addr //' | sed -e 's/^[ \t]*//')
	echo '    addr  - ' $iface_addr
	echo ' --------------------------------'
	echo


#	Set channel
	read -p " Do you want to set the channel? [y/N] " -n 1 -r
	echo
	if [[ $REPLY =~ ^[Yy]$ ]]
	then
		read -p " What channel do you want to set? " chan
#		Documentation:
#		iw dev <devname> set channel <channel> [NOHT|HT20|HT40+|HT40-|5MHz|10MHz|80MHz]
#		iw dev <devname> set freq <freq> [NOHT|HT20|HT40+|HT40-|5MHz|10MHz|80MHz]
#		iw dev <devname> set freq <control freq> [5|10|20|40|80|80+80|160] [<center1_freq> [<center2_freq>]]
#		Select one or modify as required:
		iw dev $iface0mon set channel $chan
#		iw dev $iface0mon set channel $chan HT40-		
#		iw dev $iface0mon set channel $chan 80MHz
#		To test if channel was set correctly:
#		aireplay-ng --test <wlan0>
	fi


#	Display interface settings
	clear
	echo
	echo ' --------------------------------'
	echo -e "    ${SCRIPT_NAME} ${SCRIPT_VERSION}"
	echo ' --------------------------------'
	echo '    WiFi Interface:'
	echo '             '$iface0
	echo ' --------------------------------'
	iface_name=$(iw dev $iface0mon info | grep 'Interface' | sed 's/Interface //' | sed -e 's/^[ \t]*//')
	echo '    name  - ' $iface_name
	iface_type=$(iw dev $iface0mon info | grep 'type' | sed 's/type //' | sed -e 's/^[ \t]*//')
	echo '    type  - ' $iface_type
	iface_state=$(ip addr show $iface0mon | grep 'state' | sed 's/.*state \([^ ]*\)[ ]*.*/\1/')
	echo '    state - ' $iface_state
	iface_addr=$(iw dev $iface0mon info | grep 'addr' | sed 's/addr //' | sed -e 's/^[ \t]*//')
	echo '    addr  - ' $iface_addr
	iface_chan=$(iw dev $iface0mon info | grep 'channel' | sed 's/channel //' | sed -e 's/^[ \t]*//')
	echo '    chan  - ' $chan
	iface_txpw=$(iw dev $iface0mon info | grep 'txpower' | sed 's/txpower //' | sed -e 's/^[ \t]*//')
	echo '    txpw  - ' $iface_txpw
	echo ' --------------------------------'
	echo


#	Set txpw
	read -p " Do you want to set the txpower? [y/N] " -n 1 -r
	echo
	if [[ $REPLY =~ ^[Yy]$ ]]
	then
		echo " Note: Some USB WiFi adapters will not allow the txpw to be set."
		read -p " What txpw setting do you want to attempt to set? ( e.g. 2300 = 23 dBm ) " iface_txpw
		iw dev $iface0mon set txpower fixed $iface_txpw
	fi


#	Display interface settings
	clear
	echo
	echo ' --------------------------------'
	echo -e "    ${SCRIPT_NAME} ${SCRIPT_VERSION}"
	echo ' --------------------------------'
	echo '    WiFi Interface:'
	echo '             '$iface0
	echo ' --------------------------------'
	iface_name=$(iw dev $iface0mon info | grep 'Interface' | sed 's/Interface //' | sed -e 's/^[ \t]*//')
	echo '    name  - ' $iface_name
	iface_type=$(iw dev $iface0mon info | grep 'type' | sed 's/type //' | sed -e 's/^[ \t]*//')
	echo '    type  - ' $iface_type
	iface_state=$(ip addr show $iface0mon | grep 'state' | sed 's/.*state \([^ ]*\)[ ]*.*/\1/')
	echo '    state - ' $iface_state
	iface_addr=$(iw dev $iface0mon info | grep 'addr' | sed 's/addr //' | sed -e 's/^[ \t]*//')
	echo '    addr  - ' $iface_addr
	iface_chan=$(iw dev $iface0mon info | grep 'channel' | sed 's/channel //' | sed -e 's/^[ \t]*//')
	echo '    chan  - ' $chan
	iface_txpw=$(iw dev $iface0mon info | grep 'txpower' | sed 's/txpower //' | sed -e 's/^[ \t]*//')
	echo '    txpw  - ' $iface_txpw
	echo ' --------------------------------'
	echo


#	Interface ready
	echo " The Interface is now ready for Monitor Mode use."
	echo
	echo " You can place this terminal in the background"
	echo " while you run any applications you wish to run."
	echo
	read -p " Press any key to continue... " -n 1 -r
	echo


#	Return the adapter to original settings or not
	read -p " Do you want to return the adapter to original settings? [Y/n] " -n 1 -r
	if [[ $REPLY =~ ^[Nn]$ ]]
	then
#		Display interface settings
		clear
		echo
		echo ' --------------------------------'
		echo -e "    ${SCRIPT_NAME} ${SCRIPT_VERSION}"
		echo ' --------------------------------'
		echo '    WiFi Interface:'
		echo '             '$iface0
		echo ' --------------------------------'
		iface_name=$(iw dev $iface0mon info | grep 'Interface' | sed 's/Interface //' | sed -e 's/^[ \t]*//')
		echo '    name  - ' $iface_name
		iface_type=$(iw dev $iface0mon info | grep 'type' | sed 's/type //' | sed -e 's/^[ \t]*//')
		echo '    type  - ' $iface_type
		iface_state=$(ip addr show $iface0mon | grep 'state' | sed 's/.*state \([^ ]*\)[ ]*.*/\1/')
		echo '    state - ' $iface_state
		iface_addr=$(iw dev $iface0mon info | grep 'addr' | sed 's/addr //' | sed -e 's/^[ \t]*//')
		echo '    addr  - ' $iface_addr
		echo ' --------------------------------'
		echo
		exit 0
	else
		ip link set dev $iface0mon down
		ip link set dev $iface0mon address $iface_addr_orig
		iw $iface0mon set type managed
		ip link set dev $iface0mon name $iface0
		ip link set dev $iface0 up
#		Enable interfering processes
		for pid in $(ps -A -o pid= -o comm= | grep ${PROCESSES} | awk '{print $1}'); do
			command kill -18 "${pid}"   # -18 = CONT
		done
#		Display interface settings
		clear
		echo
		echo ' --------------------------------'
		echo -e "    ${SCRIPT_NAME} ${SCRIPT_VERSION}"
		echo ' --------------------------------'
		echo '    WiFi Interface:'
		echo '             '$iface0
		echo ' --------------------------------'
		iface_name=$(iw dev $iface0 info | grep 'Interface' | sed 's/Interface //' | sed -e 's/^[ \t]*//')
		echo '    name  - ' $iface_name
		iface_type=$(iw dev $iface0 info | grep 'type' | sed 's/type //' | sed -e 's/^[ \t]*//')
		echo '    type  - ' $iface_type
		iface_state=$(ip addr show $iface0 | grep 'state' | sed 's/.*state \([^ ]*\)[ ]*.*/\1/')
		echo '    state - ' $iface_state
		iface_addr=$(iw dev $iface0 info | grep 'addr' | sed 's/addr //' | sed -e 's/^[ \t]*//')
		echo '    addr  - ' $iface_addr
		echo ' --------------------------------'
		echo
		exit 0
	fi
else
	clear
	echo
	echo " ERROR: Please provide an existing interface as parameter!"
	echo -e " Usage: $ sudo ./$SCRIPT_NAME [interface:wlan0]"
	echo " Tip:   $ iw dev"
	echo
	exit 1
fi
