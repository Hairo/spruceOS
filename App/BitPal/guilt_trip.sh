#!/bin/sh

. /mnt/SDCARD/spruce/scripts/helperFunctions.sh

display -t "$1" -s 36 -p 50 --confirm
if confirm; then
    # user pressed A - guilt trip denied. exit!
    exit 1
else
    # user pressed B to go back to BitPal!
    exit 0
fi