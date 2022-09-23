#!/bin/bash
#
#
# Purpose: Make it easier to edit the driver options file.
#
# To make this file executable:
#
# $ chmod +x edit-options.sh
#
# To execute this file:
#
# $ sudo ./edit-options.sh
#

options_file=88x2bu.conf

if (( EUID != 0 ))
then
    printf 'You must run this script with superuser (root) privileges.\n'
    printf 'Try: "sudo %s"\n' "$0"
    exit 1
fi

${EDITOR:-nano} "/etc/modprobe.d/$options_file"

read -p 'Do you want to apply the new options by rebooting now? [y/N] ' -n 1 -r || exit 1
printf '\n'    # move to a next line
if [[ $REPLY = [Yy] ]]
then
    reboot
fi

exit 0
