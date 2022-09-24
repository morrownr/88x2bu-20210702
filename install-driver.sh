#!/bin/bash

# Purpose: Install Realtek USB WiFi adapter drivers.
#
# This version of the installation script uses dkms.

SCRIPT_VERSION=20220923

options_file=88x2bu.conf
blacklist_file=rtw88_8822bu.conf

drv_name=rtl88x2bu
drv_version=5.13.1

drv_dir=$PWD

# support for NoPrompt allows non-interactive use of this script
no_prompt=0
no_clean=0

# get the options
for ((;$#;)) do
    case $1 in
      -y|--no-prompt|NoPrompt)
        no_prompt=1 ;;
      -d|--dirty|--no-clean|NoClean)
        no_clean=1 ;;
      -j*)
        printf '(dkms build ignores "%s" option)\n' "$1" ;;
      -h|--help|*)
        cat <<- EndOfHelp
		Usage: $0 [--no-prompt|-y] [--no-clean|-d]
		       $0 --help|-h
		    --no-prompt  non-interactive mode
		    --no-clean   use existing built objects
		    --help       show this message
		EndOfHelp
        [[ $1 = -h || $1 = --help ]] # use zero exit status when help requested
        exit
        ;;
    esac
    shift
done

# check to ensure sudo was used
if (( EUID != 0 ))
then
    printf 'You must run this script with superuser (root) privileges.\n'
    printf 'Try: "sudo %s"\n' "$0"
    exit 1
fi

# check for previous installation
if [[ -d "/usr/src/$drv_name-$drv_version" ]]
then
    printf 'It appears that this driver may already be installed.\n'
    printf 'You will need to run the following before reattempting installation.\n'
    printf '$ sudo ./remove-driver.sh\n'
    exit 1
fi

# information that helps with bug reports

clear

# displays script name and version
printf 'Running %s version %s\n' "${0##*/}" "$SCRIPT_VERSION"

# kernel
uname -r

# architecture - for ARM: aarch64 = 64 bit, armv7l = 32 bit
uname -m

printf 'Starting installation...\n'

# the add command requires source in "/usr/src/$drv_name-$drv_version"
printf 'Copying source files to: %s\n' "/usr/src/$drv_name-$drv_version"
cp -rf "$drv_dir" "/usr/src/$drv_name-$drv_version"

(( no_clean )) ||
find "/usr/src/$drv_name-$drv_version" '(' -name '*.o' -o -name '*.ko' -o -name '*.o.cmd' ')' -delete

# sets module parameters (driver options)
# blacklist the in-kernel module (driver) so that there is no conflict
printf 'Copying options and blacklist files into: %s\n' "/etc/modprobe.d"
cp -fv "$options_file" "$blacklist_file" /etc/modprobe.d

dkms add -m "$drv_name" -v "$drv_version" || {
    status=$?
    printf 'An error occurred. dkms add error = %d\n' "$status"
    printf 'Please report this error.\n'
    printf 'Please copy all screen output and paste it into the report.\n'
    printf 'You will need to run the following before reattempting installation.\n'
    printf '$ sudo ./remove-driver.sh\n'
    exit "$status"
}

dkms build -m "$drv_name" -v "$drv_version" || {
    status=$?
    printf 'An error occurred. dkms build error = %d\n' "$status"
    printf 'Please report this error.\n'
    printf 'Please copy all screen output and paste it into the report.\n'
    printf 'You will need to run the following before reattempting installation.\n'
    printf '$ sudo ./remove-driver.sh\n'
    exit "$status"
}

dkms install -m "$drv_name" -v "$drv_version" || {
    status=$?
    printf 'An error occurred. dkms install error = %d\n' "$status"
    printf 'Please report this error.\n'
    printf 'Please copy all screen output and paste it into the report.\n'
    printf 'You will need to run the following before reattempting installation.\n'
    printf '$ sudo ./remove-driver.sh\n'
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
