#!/bin/sh

. /mnt/SDCARD/spruce/scripts/helperFunctions.sh
. /mnt/SDCARD/App/BitPal/BitPalFunctions.sh


# Launch main BitPal menu
export PYSDL2_DLL_PATH="/mnt/SDCARD/App/PyUI/dll"
export LD_LIBRARY_PATH="$LD_LIBRARY_PATH:/usr/miyoo/lib"
call_menu "BitPal - Main" "main.json"

set_random_negative_mood ##### just for testing
case "$mood" in
    sad|angry|neutral|surprised)
        GUILT_TRIP="$(get_random_guilt_trip)"
        display --okay -t "$GUILT_TRIP" -s 36 -p 50
        sleep 0.1
        ;;
    *) 
        true
        ;;
esac
