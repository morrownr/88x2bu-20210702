#!/bin/sh

# Warning: Do not run this script in a terminal. It is designed to be
#          run from another script.

# SMEM needs to be set here if dkms build is not initiated by install-driver.sh
SMEM=$(LANG=C free | awk '/Mem:/ { print $2 }')

# sproc needs to be set here if dkms build is not initiated by install-driver.sh
sproc=$(nproc)

# calculate number of cores to be used in order to avoid Out of Memory
# condition in low-RAM systems by limiting core usage.
# this section of code is also in the file install-driver.sh and that 
# code should stay the same as this code.
if [ "$sproc" -gt 1 ]; then
	if [ "$SMEM" -lt 1400000 ]; then
		sproc=2
	fi
	if [ "$SMEM" -lt 700000 ]; then
		sproc=1
	fi
fi

kernelver=${kernelver:-$(uname -r)}
make "-j$sproc" "KVER=$kernelver" "KSRC=/lib/modules/$kernelver/build"
