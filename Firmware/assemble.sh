#!/bin/sh 
ca65 Warning.asm -o warning.o
ca65 Firmware.asm -o firmware.o --listing Firmware.lst

ld65 -t none warning.o firmware.o -o Firmware.bin
# assumes ProDOS-Utilities is in your path: https://github.com/tjboldt/ProDOS-Utilities
rm BlankDriveWithFirmware.po
ProDOS-Utilities -c create -d BlankDriveWithFirmware.po -v ROM -s 2048
ProDOS-Utilities -b 0x0001 -c writeblock -d BlankDriveWithFirmware.po -i Firmware.bin
ProDOS-Utilities -b 0x0001 -c readblock -d BlankDriveWithFirmware.po
ProDOS-Utilities -c ls -d BlankDriveWithFirmware.po

