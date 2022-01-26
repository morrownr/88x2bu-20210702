#!/bin/bash

SCRIPT_NAME="start-mon.sh"
SCRIPT_VERSION="20220125"


# Purpose: Start and configure monitor mode on the provided interface

# Usage: $ sudo ./start-mon.sh [interface:wlan0]


# Set color definitions (https://en.wikipedia.org/wiki/ANSI_escape_code)
							# Black        0;30     Dark Gray     1;30
LightRed='\033[1;31m'		# Red          0;31     Light Red     1;31
LightGreen='\033[1;32m'		# Green        0;32     Light Green   1;32
Yellow='\033[1;33m'			# Brown/Orange 0;33     Yellow        1;33
							# Blue         0;34     Light Blue    1;34
							# Purple       0;35     Light Purple  1;35
LightCyan='\033[1;36m'		# Cyan         0;36     Light Cyan    1;36
							# Light Gray   0;37     White         1;37
NoColor='\033[0m'

clear

# Check that sudo was used to start the script
if [[ $EUID -ne 0 ]]
then
	echo -e "${LightRed}ERROR: You must run this script with superuser (root) privileges."
#	echo -e "${NoColor}Try: ${LightCyan}\"sudo ./${SCRIPT_NAME}\""
	echo -e "${NoColor}Try: $ ${LightCyan}sudo ./${SCRIPT_NAME}"
	echo -e "${NoColor}"
	exit 1
fi


# Assign default monitor mode interface name
iface0mon='wlan0mon'


# Assign default channel
chan=6


# Activate option to set automatic or manual interface mode
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
#	ps -A -o pid=PID -o comm=Name | grep "${PROCESSES}\|PID"
	badProcs=$(ps -A -o pid=PID -o comm=Name | grep "${PROCESSES}\|PID")
	for pid in $(ps -A -o pid= -o comm= | grep ${PROCESSES} | awk '{print $1}'); do
		command kill -19 "${pid}"   # -19 = STOP
	done
	clear
	echo
	echo ' The following processes have been stopped:'
	echo -e "${LightRed}"
	echo "${badProcs}"
	echo -e "${NoColor}"
	echo
	echo ' Note: The above processes will be returned'
	echo ' to a normal state at the end of this script.'
	echo
	read -p " Press any key to continue... " -n 1 -r
	
# 	Disable interfering processes using airmon-ng
#	clear
#	echo
#	read -p " Do you want to use airmon-ng to disable interfering processes? [y/N] " -n 1 -r
#	echo
#	if [[ $REPLY =~ ^[Yy]$ ]]
#	then
#		airmon-ng check kill
#		read -p " Press any key to continue. " -n 1 -r
#	fi


#	Display interface settings
	clear
	echo -e "${LightGreen}"
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
	echo -e "${NoColor}"		


#	Set addr (has to be done before renaming the interface)
	iface_addr_orig=$iface_addr
	read -p " Do you want to set a new addr? [y/N] " -n 1 -r
	echo
	if [[ $REPLY =~ ^[Yy]$ ]]
	then
		read -p " What addr do you want? ( e.g. 12:34:56:78:90:ab ) " iface_addr
		ip link set dev $iface0 address $iface_addr
	fi
#	iface_addr=$(iw dev $iface0 info | grep 'addr' | sed 's/addr //' | sed -e 's/^[ \t]*//')
#	echo '    addr  - ' $iface_addr 
#	exit 1


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
	iw dev $iface0 set monitor control


#	Rename interface
	ip link set dev $iface0 name $iface0mon


#	Bring the interface up
	ip link set dev $iface0mon up


#	Run airodump-ng
#	airodump-ng will display a list of detected access points and clients
#	https://www.aircrack-ng.org/doku.php?id=airodump-ng
#	https://en.wikipedia.org/wiki/Regular_expression
#	Display interface settings
	clear
	echo -e "${LightGreen}"
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
	echo -e "${NoColor}"
	echo ' airodump-ng can display a list'
	echo ' of detected access points and'
	echo ' connected clients.'
	echo
	read -p " Do you want to run airodump-ng? [y/N] " -n 1 -r
	echo
	if [[ $REPLY =~ ^[Yy]$ ]]
	then
		clear
		echo
		echo -e " airodump-ng can receive and interpret key strokes while running..."
		echo
		echo -e " [a]: Select active areas by cycling through the display options"
		echo -e " [d]: Reset sorting to defaults"
		echo -e " [i]: Invert sorting algorithm"
		echo -e " [m]: Mark the selected AP"
		echo -e " [r]: (De-)Activate realtime sorting"
		echo -e " [s]: Change column to sort by"
		echo -e " [SPACE]: Pause display redrawing/ Resume redrawing"
		echo -e " [TAB]: Enable/Disable scrolling through AP list"
		echo -e " [UP]: Select the AP prior to the currently marked AP if available"
		echo -e " [DOWN]: Select the AP after the currently marked AP if available"
		echo -e " [q] - quit"
		echo
		read -p " Press any key to continue... " -n 1 -r
		echo

#		Select option
#
#		1) shows hidden ESSIDs
#		airodump-ng -c 1-165 -a --ignore-negative-one $iface0mon
#
#		2) does not show hidden ESSIDs
		airodump-ng -c 1-165 -a -n 20 --uptime --ignore-negative-one --essid-regex '^(?=.)^(?!.*CoxWiFi)' $iface0mon
	fi


#	Set channel
	read -p " Do you want to set the channel? [y/N] " -n 1 -r
	echo
	if [[ $REPLY =~ ^[Yy]$ ]]
	then
		read -p " What channel do you want to set? " chan
#		ip link set dev $iface0mon down
		iw dev $iface0mon set channel $chan
#		ip link set dev $iface0mon up
	fi


#	Display interface settings
	clear
	echo -e "${LightGreen}"
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
	echo -e "${NoColor}"


#	Set txpw
	read -p " Do you want to set the txpower? [y/N] " -n 1 -r
	echo
	if [[ $REPLY =~ ^[Yy]$ ]]
	then
		echo -e "${Yellow} Note: Some USB WiFi adapters will not allow the txpw to be set.${NoColor}"
		read -p " What txpw setting do you want to attempt to set? ( e.g. 2300 = 23 dBm ) " iface_txpw
#		ip link set dev $iface0mon down
		iw dev $iface0mon set txpower fixed $iface_txpw
#		ip link set dev $iface0mon up
	fi


#	Display interface settings
	clear
	echo -e "${LightGreen}"
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
	echo -e "${NoColor}"


#	Interface ready
	echo " The Interface is now ready for Monitor Mode use."
	echo
	echo " You can place this terminal in the background"
	echo " while you run any applications you wish to run."
	echo
	read -p " Press any key to continue... " -n 1 -r
	echo


#	Return the adapter to original settings
	read -p " Do you want to return the adapter to original settings? [Y/n] " -n 1 -r
	if [[ $REPLY =~ ^[Nn]$ ]]
	then
#		ip link set dev $iface0mon up
#		Display interface settings
		clear
		echo -e "${LightGreen}"
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
		echo -e "${NoColor}"
	else
		ip link set dev $iface0mon down
		ip link set dev $iface0mon address $iface_addr_orig
		iw $iface0mon set type managed
		ip link set dev $iface0mon name $iface0
		ip link set dev $iface0 up
#		Enable interfering processes
#		PROCESSES="wpa_action\|wpa_supplicant\|wpa_cli\|dhclient\|ifplugd\|dhcdbd\|dhcpcd\|udhcpc\|NetworkManager\|knetworkmanager\|avahi-autoipd\|avahi-daemon\|wlassistant\|wifibox\|net_applet\|wicd-daemon\|wicd-client\|iwd"
#		unset match
#		match="$(ps -A -o comm= | grep ${PROCESSES} | grep -v grep | wc -l)"
#		ps -A -o pid=PID -o comm=Name | grep "${PROCESSES}\|PID"
		for pid in $(ps -A -o pid= -o comm= | grep ${PROCESSES} | awk '{print $1}'); do
			command kill -18 "${pid}"   # -18 = CONT
		done
#		Display interface settings
		clear
		echo -e "${LightGreen}"
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
		echo -e "${NoColor}"
	fi
	exit 0
else
	echo -e "${LightRed}ERROR: Please provide an existing interface as parameter! ${NoColor}"
	echo -e "${NoColor}Usage: $ ${LightCyan}sudo ./$SCRIPT_NAME [interface:wlan0] ${NoColor}"
	echo -e "${NoColor}Tip:   $ ${LightCyan}iw dev ${NoColor}(displays available interfaces)"
	echo
	exit 1
fi
