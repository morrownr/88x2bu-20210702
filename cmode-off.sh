#!/bin/bash
#
# 2021-12-18
#
# Purpose: Turn Concurrent Mode off.
#
# To make this file executable:
#
# $ chmod +x edit-options.sh
#
# To execute this file:
#
# $ ./cmode-off.sh

sed -i '/^CONFIG_CONCURRENT_MODE *=/ s/ *=.*/ = n/' Makefile || {
    status=$?
    printf 'An error occurred and Concurrent Mode was not turned off in Makefile.\n'
    exit "$status"
}

printf 'Concurrent Mode was turned off in Makefile as planned.\n'
exit 0
