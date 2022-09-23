#!/bin/bash
#
# 2021-12-03
#
# Purpose: Turn Concurrent Mode on.
#
# To make this file executable:
#
# $ chmod +x edit-options.sh
#
# To execute this file:
#
# $ ./cmode-on.sh

sed -i '/^CONFIG_CONCURRENT_MODE *=/ s/ *=.*/ = y/' Makefile || {
    status=$?
    printf 'An error occurred and Concurrent Mode was not turned on in Makefile.\n'
    exit "$status"
}

printf 'Concurrent Mode was turned on in Makefile as planned.\n'
exit 0
