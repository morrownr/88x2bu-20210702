#!/bin/bash

# Purpose: Remove Realtek USB WiFi adapter drivers.
#
# This version of the removal script does not use dkms.

SCRIPT_NAME="remove-driver-no-dkms.sh"
SCRIPT_VERSION="20220913"
OPTIONS_FILE="88x2bu.conf"

MODULE_NAME="88x2bu"
KVER="$(uname -r)"
KSRC="/lib/modules/${KVER}/build"
MODDESTDIR="/lib/modules/${KVER}/kernel/drivers/net/wireless/"

BLACKLIST_FILE="rtw88_8822bu.conf"

# support for NoPrompt allows non-interactive use of this script
NO_PROMPT=0

# get the options
while [ $# -gt 0 ]
do
	case $1 in
		NoPrompt)
			NO_PROMPT=1 ;;
		*h|*help|*)
			echo "Syntax $0 <NoPrompt>"
			echo "       NoPrompt - noninteractive mode"
			echo "       -h|--help - Show help"
			exit 1
			;;
	esac
	shift
done

# check to ensure sudo was used
if [[ $EUID -ne 0 ]]
then
	echo "You must run this script with superuser (root) privileges."
	echo "Try: \"sudo ./${SCRIPT_NAME}\""
	exit 1
fi

# displays script name and version
echo "Running ${SCRIPT_NAME} version ${SCRIPT_VERSION}"

make uninstall
RESULT=$?

if [[ ("$RESULT" = "0")]]
then
	echo "Deleting ${OPTIONS_FILE} from /etc/modprobe.d"
	rm -f /etc/modprobe.d/${OPTIONS_FILE}
	echo "Deleting ${BLACKLIST_FILE} from /etc/modprobe.d"
	rm -f /etc/modprobe.d/${BLACKLIST_FILE}
	echo "The driver was removed successfully."
	echo "You may now delete the driver directory if desired."
else
	echo "An error occurred. Error = ${RESULT}"
	echo "Please report this error."
	exit $RESULT
fi

# if NoPrompt is not used, ask user some questions to complete removal
if [ $NO_PROMPT -ne 1 ]
then
	read -p "Do you want to reboot now? (recommended) [y/N] " -n 1 -r
	echo
	if [[ $REPLY =~ ^[Yy]$ ]]
	then
		reboot
	fi
fi

exit 0
