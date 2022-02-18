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

sed -i 's/CONFIG_PLATFORM_I386_PC = y/CONFIG_PLATFORM_I386_PC = n/g' Makefile
RESULT=$?

if [[ "$RESULT" != "0" ]]; then
	echo "An error occurred and I386 support was not turned off in Makefile."
	exit 1
else
	echo "I386 support was turned off in Makefile as planned."
fi

sed -i 's/CONFIG_PLATFORM_ARM_RPI = n/CONFIG_PLATFORM_ARM_RPI = y/g' Makefile
RESULT=$?

if [[ "$RESULT" != "0" ]]; then
	echo "An error occurred and Raspberry Pi OS (32 bit) support was not turned on in Makefile."
	exit 1
else
	echo "Raspberry Pi OS (32 bit) support was turned on in Makefile as planned."
	exit 0
fi
