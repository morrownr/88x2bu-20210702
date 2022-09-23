#!/bin/bash
#
# Purpose: Save a log file with RTW lines only.
#
# To make this file executable:
#
# $ chmod +x save-log.sh
#
# To execute this file:
#
# $ sudo ./edit-options.sh
#

if (( EUID != 0 )); then
    printf 'You must run this script with superuser (root) privileges.\n'
    printf 'Try: "sudo %s"\n' "${*:0}"
    exit 1
fi

# Deletes existing log
rm -f -- rtw.log

dmesg |
 cut -d ']' -f2- |
  grep RTW >> rtw.log || {
    status=$?

    printf 'An error occurred while running: %s\n' "${0##*}"
    printf 'Did you set a log level > 0 ?\n'
    exit "$status"
}

printf 'rtw.log saved successfully.\n'
exit 0
