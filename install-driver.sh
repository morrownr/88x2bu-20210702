#!/bin/bash

# Purpose: Build and Install Realtek USB WiFi adapter drivers.
#
# Use Dynamic Kernel Module Support (DKMS) to build and install the driver.

SCRIPT_VERSION=20220925

options_file=88x2bu.conf
blacklist_file=rtw88_8822bu.conf

drv_name=rtl88x2bu
drv_version=5.14.0

installed_blacklist_file=/etc/modprobe.d/$blacklist_file
installed_options_file=/etc/modprobe.d/$options_file
installed_driver=/usr/src/$drv_name-$drv_version

#      Start               End
Tmks=$'\e[42;37;1m' Tmke=$'\e[22;39;49m'    # Menu-Key
Twas=$'\e[33m'      Twae=$'\e[39m'          # WArning
Tins=$'\e[1m'       Tine=$'\e[22m'          # INstruction

Tdr=$'\e[47m\e[K\e[49m'                     # Diff-Ruler
Tcl=$'\r\e[K'                               # Clear-Line

# check to ensure sudo was used
if (( EUID != 0 ))
then
    printf '%sYou must run this script with superuser (root) privileges.%s\n' "$Twas" "$Twae"
    printf 'Try: "%ssudo %s%s"\n' "$Tins" "$0" "$Tine"
    exit 1
fi

# check for previous installation
if [[ -d "$installed_driver" ]]
then
    printf 'It appears that this driver may already be installed.\n'
    printf 'You will need to run the following before reattempting installation.\n'
    printf '%s$ sudo ./remove-driver.sh\%sn'
    exit 1
fi

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
      -n|--dry-run|\
      --nb|--no-build)
        no_build=1 ;;
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

# Install a config file, using a similar method to dpkg -i
managed_file_installation() {
    local src=$1 installed=$2 desc=$3 old
    if [[ -e $installed ]]
    then
        old=
    else
        old=/tmp/$$-$src
        trap 'rm -f "$old"' EXIT
        cp -Tf "$installed" "$old"
    fi
    while :
    do
        Kcont=XX Kdiff=XX Kedit=XX Krevt=XX Kinst=XX Kvimd=XX   # any value that can't match a single byte
        if [[ ! -e $installed ]]
        then
            menu=( 'Install new' Quit )
            Kinst=i
        else
            menu=( Diff Edit Vimdiff Quit )
            Kcont=c Kedit=e Kvimd=v
            if [[ $old && -s $old ]] && ! cmp "$src" "$old"
            then
                menu=( 'Revert to old' "${menu[@]}" )
                Krevt=r
            fi
            if d=$( diff "$src" "$installed" )
            then
                menu=( 'Continue' "${menu[@]}" )
            else
                menu=( 'Continue with existing' 'Install new' "${menu[@]}" )
                Kdiff=d Kinst=i
                printf '\n%sExisting %s file differs from the package default%s\n' "$Twas" "$desc" "$Twae"
            fi
        fi
        printf '\nChoose:'
        for c in "${menu[@]}" ; do printf ' %s' "$Tmks${c:0:1}$Tmke${c:1}" ; done
        printf '? '
        read -rs -N1 key || exit
        printf '\r\e[K'
        case ${key,,} in
          [qx]) exit ;;
          $Kcont) break ;;
          $Kdiff) printf '%s\n%s\n%s' "$Tdr" "$d" "$Tdr" ;;
          $Kedit) ${EDITOR:-nano} "$installed" ;;
          $Kinst) cp -Tfv "$src" "$installed" ;;
          $Krevt) cp -Tfv "$old" "$installed" ;;
          $Kvimd) vimdiff "$installed" "$src" ;;
        esac
    done
    rm -f "$old" ; trap - EXIT
}

# information that helps with bug reports

# displays script name and version
printf 'Running %s version %s\n' "${0##*/}" "$SCRIPT_VERSION"

# kernel
uname -r

# architecture - for ARM: aarch64 = 64 bit, armv7l = 32 bit
uname -m

printf 'Starting installation...\n'

if (( no_build ))
then
    printf 'Build & install skipped.\n'
else
    # the add command requires source in "/usr/src/$drv_name-$drv_version"
    printf 'Copying source files into %s\n' "$installed_driver/"
    cp -rf "./" "$installed_driver/"
    (( no_clean )) ||
    find "$installed_driver" '(' -name '*.o' -o -name '*.ko' -o -name '*.o.cmd' ')' -delete

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
        printf '$ %ssudo %s%s\n' "$Tins" "${0/install/remove}" "$Tine"
        exit "$status"
    }

    dkms install -m "$drv_name" -v "$drv_version" || {
        status=$?
        printf 'An error occurred. dkms install error = %d\n' "$status"
        printf 'Please report this error.\n'
        printf 'Please copy all screen output and paste it into the report.\n'
        printf 'You will need to run the following before reattempting installation.\n'
        printf '$ %ssudo %s%s\n' "$Tins" "${0/install/remove}" "$Tine"
        exit "$status"
    }

    printf 'The driver was installed successfully.\n'
fi

# unblock wifi
rfkill unblock wlan

# Blacklist the in-kernel module (driver) so that there is no conflict
printf 'Installing module blacklist as %s\n' "$installed_blacklist_file"
cp -Tfv "$blacklist_file" "$installed_blacklist_file"

# Set module parameters (driver options)

# Install default if config file doesn't already exist, or overwrite it if
# non-interactive.
if (( no_prompt )) || [[ ! -e $installed_options_file ]]
then
    printf 'Installing default options file as %s\n' "$installed_options_file"
    cp -Tfv "$options_file" "$installed_options_file"
fi

# if NoPrompt is not used, ask user some questions to complete installation
if (( ! no_prompt ))
then
    managed_file_installation "$options_file" "$installed_options_file" 'Driver options'

    read -p 'Do you want to reboot now? (recommended) [r/N] ' -n 1 -r || exit 1
    printf %s "$Tcl"
    if [[ $REPLY = [Rr] ]]
    then
        read -p 'Confirm reboot? [c/N] ' -n1 -r || exit 1
        printf %s "$Tcl"
        if [[ $REPLY = [Cc] ]]
        then
            reboot
        fi
    fi
fi

exit 0
