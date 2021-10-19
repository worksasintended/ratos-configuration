#!/bin/bash
# NOTE: This script ONLY WORKS if the board has already been flashed with
# klipper via SD card PRIOR to installing the boot0 jumper.
# The first time the board is booted after the jumper has been installed
# the board needs to be flashed via the dfu vendor:device id. After that
# it can be flashed via the /dev/btt-octopus-11 path, but it then fails
# to exit dfu mode, and then one needs to flash it yet again with the
# vendor:device id. Then it correctly exits DFU mode. Except those times
# where it doesn't, for that we have a 3rd pass...


MCU=/dev/prusa-i3-mk3sp
VENDORDEVICEID=2c99:0002
cp -f /home/pi/klipper_config/config/boards/einsy-rambo-prusa/firmware.config /home/pi/klipper/.config
cd /home/pi/klipper
make olddefconfig
make clean
make
sudo service klipper stop
if [ -e $MCU ]; then
    echo "Flashing Prusa i3 Einsy Rambo via path"
    make flash FLASH_DEVICE=$MCU
else
    echo "Flashing Prusa i3 Einsy Rambo via vendor and device ids - 1st pass"
    make flash FLASH_DEVICE=$VENDORDEVICEID
fi
sleep 5
if [ -e $MCU ]; then
    echo "Flashing Successful!"
else
    echo "Flashing Prusa i3 Einsy Rambo via vendor and device ids - 2nd pass"
    make flash FLASH_DEVICE=$VENDORDEVICEID

    sleep 5
    if [ -e $MCU ]; then
        echo "Flashing Successful!"
    else
        echo "Flashing board via vendor and device ids - 3rd pass"
        make flash FLASH_DEVICE=$VENDORDEVICEID
        if [ $? -e 0 ]; then
            echo "Flashing board successful!"
        else
            echo "Flashing board failed :("
            sudo service klipper start
            exit 1
        fi
    fi
fi


sudo service klipper start