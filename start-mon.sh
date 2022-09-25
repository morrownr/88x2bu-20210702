#!/bin/bash

SCRIPT_VERSION=20220923

# Purpose: Start and configure monitor mode on the provided interface

# Usage: $ sudo ./start-mon.sh [interface:wlan0]

# There is no filename globbing in this script, so disable it to stop accidents
set -f

# Check that sudo was used to start the script
if (( EUID != 0 ))
then
    printf '\n ERROR: You must run this script with superuser (root) privileges.\n'
    printf ' Try: "sudo %s"\n\n' "${*:0}"
    exit 1
fi

# Add code to check if iw and ip are installed

# Ensure WiFi radio is not blocked
sudo rfkill unblock wlan

# Assign default monitor mode interface name
iface0mon=wlan0mon

# Assign default channel
chan=6

# Activate option to set automatic (1) or manual (2) interface mode
#
# Option 1: if you only have one wlan interface (automatic detection)
# iface0=$( iw dev |
#           sed -e '/^[[:space:]]*Interface[[:space:]]*/! d' -e 's///' )
#
# Option 2: if you have more than one wlan interface (default wlan0)
iface0=${1:-wlan0}

get_if_info() {
    local iface=$1 ii ij

    # shellcheck ignore=SC1007
    iface_name= iface_type= iface_addr= iface_chan= iface_txpw= iface_state=

    ii=$( iw dev "$iface" info | tr -s ' \t\\\n\r' ' ' )
    ij=${ii#*' Interface '} ; [[ $ij = "$ii" ]] || iface_name=${ij%%' '*}
    ij=${ii#*' addr '}      ; [[ $ij = "$ii" ]] || iface_type=${ij%%' '*}
    ij=${ii#*' type '}      ; [[ $ij = "$ii" ]] || iface_addr=${ij%%' '*}
    ij=${ii#*' channel '}   ; [[ $ij = "$ii" ]] || iface_chan=${ij%%' '*}
    ij=${ii#*' txpower '}   ; [[ $ij = "$ii" ]] || ij=${ij%%' '*} iface_txpw=${ij%dBm}

    ij=' '$( ip addr show "$iface" | tr -s ' \t\\\n\r' ' ' )
    ij=${ii#*' state '}     ; [[ $ij = "$ii" ]] || iface_state=${ij%%' '*}
}

print_if_info() {
    local iface=$1 m n

    printf '\n --------------------------------\n'
    printf '    %-20s %s\n' "${0##*/}" "$SCRIPT_VERSION"
    printf ' --------------------------------\n'
    printf '    WiFi Interface:\n'
    printf '             %s\n' "$iface"
    printf ' --------------------------------\n'
    for m in name type state addr chan txpw
    do
        n=iface_$m ; n=${!n} ;
        [[ -n $n ]] && printf '    %-5.5s -  %s\n' "$m" "$n"
    done
    printf ' --------------------------------\n\n'
}

# str_join
#   $1      name of output variable
#   $2      joiner
#   $3...   words to be joined
# puts $3$2$4$2$5$2$6$2$7... into variable $1

str_join() { local IFS="$2" ; printf -v "$1" %s "${*:3}" ; }

# Set $iface0 down
ip link set dev "$iface0" down || {
    printf '\n ERROR: Please provide an existing interface as parameter!\n'
    printf ' Usage: $ sudo %s [interface:wlan0]\n' "$0"
    printf ' Tip:   $ iw dev\n\n'
    exit 1
}

#Suspend interfering processes
ProcNames=(
    autoipd
    avahi
    avahi
    client
    daemon
    daemon
    dhcdbd
    dhclient
    dhcpcd
    ifplugd
    iwd
    knetworkmanager
    net_applet
    NetworkManager
    udhcpc
    wicd
    wicd
    wifibox
    wlassistant
    wpa_action
    wpa_cli
    wpa_supplicant
)

IFS=$' \t\n'
pids=( $(
          # pgrep takes a RegEx pattern, which can be a pipe-separated list of alternatives
          str_join ProcPattern '|' "${ProcNames[@]}"
          pgrep -x "$ProcPattern"
        ) )   # split output on any whitespace
if  (( ${#pids[@]} > 0 ))
then

    kill -STOP "${pids[@]}"

    printf '\n The following processes have been stopped:\n\n'

    # ps -p takes a comma-separated list
    str_join pidlist ',' "${pids[@]}"
    # pidlist is defined by str_join
    # shellcheck disable=SC2154
    ps -o pid=PID,state=State,comm=Name -p "$pidlist"

    printf '\n (state T means stopped)\n\n'
    printf ' Note: The above processes can be returned\n'
    printf ' to a normal state at the end of this script.\n\n'

else
    printf '\n There are no processes that need stopping.\n\n'
fi

read -p ' Press any key to continue... ' -n 1 -r || exit

# Display interface settings
get_if_info "$iface0"
print_if_info "$iface0" 4

# Set addr (has to be done before renaming the interface)
iface_addr_orig=$iface_addr
read -p ' Do you want to set a new addr? [y/N] ' -n 1 -r || exit
printf '\n'
if [[ $REPLY = [Yy] ]]
then
    read -p ' What addr do you want? ( e.g. 12:34:56:78:90:ab ) ' iface_addr || exit
#   need code to ID bad addresses
    ip link set dev "$iface0" address "$iface_addr"
fi

# Set monitor mode
#iw dev <devname> set monitor <flag>
#   Valid monitor flags are:
#   none:     no special flags
#   fcsfail:  show frames with FCS errors
#   control:  show control frames
#   otherbss: show frames from other BSSes
#   cook:     use cooked mode
#   active:   use active mode (ACK incoming unicast packets)
#   mumimo-groupid <GROUP_ID>: use MUMIMO according to a group id
#   mumimo-follow-mac <MAC_ADDRESS>: use MUMIMO according to a MAC address
iw dev "$iface0" set monitor none

# Rename interface
ip link set dev "$iface0" name "$iface0mon"

# Bring the interface up
ip link set dev "$iface0mon" up

# Display interface settings
get_if_info "$iface0mon"
print_if_info "$iface0" 4

# Set channel
read -p ' Do you want to set the channel? [y/N] ' -n 1 -r || exit
printf '\n'
if [[ $REPLY = [Yy] ]]
then
    read -p ' What channel do you want to set? ' chan || exit
# Documentation:
#   iw dev "$devname" set channel "$channel"   [NOHT|HT20|HT40+|HT40-|5MHz|10MHz|80MHz]
#   iw dev "$devname" set freq "$freq"         [NOHT|HT20|HT40+|HT40-|5MHz|10MHz|80MHz]
#   iw dev "$devname" set freq "$control_freq" [5|10|20|40|80|80+80|160] ["$center1_freq" ["$center2_freq"]]
# Select one or modify as required:
    iw dev "$iface0mon" set channel "$chan"
#   iw dev "$iface0mon" set channel "$chan" HT40-
#   iw dev "$iface0mon" set channel "$chan" 80MHz
# To test if channel was set correctly:
#   aireplay-ng --test <wlan0>
fi

# Display interface settings

get_if_info "$iface0mon"
print_if_info "$iface0" 6

# Set txpw
read -p ' Do you want to set the txpower? [y/N] ' -n 1 -r || exit
printf '\n'
if [[ $REPLY = [Yy] ]]
then
    printf ' Note: Some USB WiFi adapters will not allow the txpw to be set.\n'
    read -p ' What txpw setting do you want to attempt to set? ( e.g. 2300 = 23 dBm ) ' iface_txpw || exit
    iw dev "$iface0mon" set txpower fixed "$iface_txpw"
fi

# Display interface settings
get_if_info "$iface0mon"
print_if_info "$iface0" 6

# Interface ready
printf ' The Interface is now ready for Monitor Mode use.\n\n'
printf ' You can place this terminal in the background\n'
printf ' while you run any applications you wish to run.\n\n'
read -p ' Press any key to continue... ' -n 1 -r || exit
printf '\n'

# Return the adapter to original settings or not
read -p ' Do you want to return the adapter to original settings? [Y/n] ' -n 1 -r || exit
if [[ $REPLY = [Nn] ]]
then
#   Display interface settings
    get_if_info "$iface0mon"
    print_if_info "$iface0" 4
else
    ip link set dev "$iface0mon" down
    ip link set dev "$iface0mon" address "$iface_addr_orig"
    iw "$iface0mon" set type managed
    ip link set dev "$iface0mon" name "$iface0"
    ip link set dev "$iface0" up
#   Display interface settings
    get_if_info "$iface0"
    print_if_info "$iface0" 4
fi

if (( ${#pids[@]} > 0 ))
then
    read -p ' Do you want to resume the stopped processes? [Y/n] ' -n 1 -r || exit
    if [[ $REPLY = [Yy] ]]
    then
        # Enable interfering processes
        kill -CONT "${pids[@]}"
    fi
fi

exit 0
