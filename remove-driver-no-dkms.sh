#!/bin/bash

# Purpose: Remove Realtek USB WiFi adapter drivers.
#
# This version of the removal script does not use dkms.

SCRIPT_VERSION=20220923

options_file=88x2bu.conf
blacklist_file=rtw88_8822bu.conf

# check to ensure sudo was used
if (( EUID != 0 ))
then
	printf 'You must run this script with superuser (root) privileges.\n'
	printf 'Try: "sudo %s"\n' "${*:0}"
	exit 1
fi

printf 'Running %s version %s\n' "${0##*/}" "$SCRIPT_VERSION"

# support for NoPrompt allows non-interactive use of this script
no_prompt=0

# get the options
for ((;$#;)) do
    case $1 in
      NoPrompt)
        no_prompt=1 ;;
      -h|--help|*)
        cat <<- EndOfHelp
		Usage: $0 [NoPrompt]
		       $0 --help
		    NoPrompt - noninteractive mode
		    -h|--help - Show help
		EndOfHelp
        [[ $1 = -h || $1 = --help ]] # don't use non-zero exit status when help requested
        exit
        ;;
    esac
    shift
done

printf 'Starting removal...\n'

make uninstall || {
    status=$?
    printf 'An error occurred. Error = %u\n' "$status"
    printf 'Please report this error.\n'
    exit "$status"
}

printf 'Deleting options and blacklist files from /etc/modprobe.d'
rm -fv "/etc/modprobe.d/$options_file" "/etc/modprobe.d/$blacklist_file"

printf 'The driver was removed successfully.\n'
printf 'You may now delete the driver directory if desired.\n'

if (( ! no_prompt ))
then
    read -p 'Do you want to reboot now? (recommended) [y/N] ' -n 1 -r || exit
    printf '\n'
    if [[ $REPLY = [Yy] ]]
    then
        reboot
    fi
fi

exit 0
