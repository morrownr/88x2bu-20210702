#!/bin/bash
#
# Purpose: Change settings in the Makefile to support compiling 64 bit
# operating systems for Raspberry Pi Hardware.
#
# To make this file executable:
#
# $ chmod +rx ARM64_RPI.sh
#
# To execute this file:
#
# $ ./ARM64_RPI.sh

sed -i '/^CONFIG_PLATFORM_/             s/ *=.*/ = n/
        /^CONFIG_PLATFORM_ARM64_RPI *=/ s/ *=.*/ = y/' Makefile || {
    status=$?
    printf 'An error occurred and Raspberry Pi OS (64 bit) support was not turned on in Makefile.\n'
    exit "$status"
}

printf 'Raspberry Pi OS (64 bit) support was turned on in Makefile as planned.\n'
exit 0
