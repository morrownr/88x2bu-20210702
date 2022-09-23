#!/bin/bash
#
# Purpose: Change settings in the Makefile to support compiling 32 bit
# operating systems for Raspberry Pi Hardware.
#
# To make this file executable (if necessary):
#
# $ chmod +x ARM_RPI.sh
#
# To execute this file:
#
# $ ./ARM_RPI.sh

# getconf LONG_BIT (need to work on this)

sed -i '/^CONFIG_PLATFORM_/             s/ *=.*/ = n/
        /^CONFIG_PLATFORM_ARM_RPI *=/   s/ *=.*/ = y/' Makefile || {
    status=$?
    printf 'An error occurred and Raspberry Pi OS (32 bit) support was not turned on in Makefile.\n'
    exit "$status"
}

printf 'Raspberry Pi OS (32 bit) support was turned on in Makefile as planned.\n'
exit 0
