#!/bin/bash

# Purpose: Install Realtek USB WiFi adapter drivers.
#
# This version of the installation script does not use dkms.

SCRIPT_VERSION=20220923

options_file=88x2bu.conf
blacklist_file=rtw88_8822bu.conf

# check to ensure sudo was used
if (( EUID != 0 ))
then
    printf 'You must run this script with superuser (root) privileges.\n'
    printf 'Try: "sudo %s"\n' "$0"
    exit 1
fi

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

# information that helps with bug reports

# displays script name and version
printf 'Running %s version %s\n' "${0##*/}" "$SCRIPT_VERSION"

# kernel
uname -r

# architecture - for ARM: aarch64 = 64 bit, armv7l = 32 bit
uname -m

printf 'Starting installation...\n'

# sets module parameters (driver options)
# blacklist the in-kernel module (driver) so that there is no conflict
printf 'Copying options and blacklist files into /etc/modprobe.d\n'
cp -fv "$options_file" "$blacklist_file" /etc/modprobe.d

make clean

make || {
    status=$?
    printf 'An error occurred. Error = %d\n' "$status"
    printf 'Please report this error.\n'
    printf 'Please copy all screen output and paste it into the report.\n'
    printf 'You will need to run the following before reattempting installation.\n'
    printf '$ sudo ./remove-driver-no-dkms.sh\n'
    exit "$status"
}

make install || {
    status=$?
    printf 'An error occurred. Error = %d\n' "$status"
    printf 'Please report this error.\n'
    printf 'Please copy all screen output and paste it into the report.\n'
    printf 'You will need to run the following before reattempting installation.\n'
    printf '$ sudo %s\n' "${*:0}"
    exit "$status"
}

printf 'The driver was installed successfully.\n'

# unblock wifi
rfkill unblock wlan

# if NoPrompt is not used, ask user some questions to complete installation
if (( ! no_prompt ))
then
    read -p 'Do you want to edit the driver options file now? [y/N] ' -n 1 -r || exit 1
    printf '\n'
    if [[ $REPLY = [Yy] ]]
    then
        ${EDITOR:-nano} "/etc/modprobe.d/$options_file"
    fi

    read -p 'Do you want to reboot now? (recommended) [y/N] ' -n 1 -r || exit 1
    printf '\n'
    if [[ $REPLY = [Yy] ]]
    then
        reboot
    fi
fi

exit 0
